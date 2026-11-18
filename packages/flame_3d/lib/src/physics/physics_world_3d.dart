import 'dart:math' as math;

import 'package:flame/components.dart' show Component, HasWorldRef;
import 'package:flame_3d/camera.dart' show World3D;
import 'package:flame_3d/collisions.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/physics.dart';

/// Deterministic fixed-timestep Sequential Impulse 3D rigid-body physics world.
///
/// Simulates dynamic, kinematic, and static [RigidBody3D] components with:
/// - World inverse inertia tensor updates (`R * I_local^-1 * R^T`),
/// - Multi-point normal + isotropic 2-tangent Coulomb friction impulses with
///   warm-starting,
/// - Restitution bounce,
/// - Split-impulse / NGS Baumgarte position correction,
/// - [Joint3D] constraints ([DistanceJoint3D], [BallSocketJoint3D],
///   [HingeJoint3D]), and
/// - Linear/angular velocity sleep timers.
class PhysicsWorld3D({
  Vector3? gravity,
  var double fixedTimeStep = 1.0 / 60.0,
  var int maxSubSteps = 4,
  var int velocityIterations = 8,
  var int positionIterations = 3,
  var double sleepLinearThreshold = 0.08,
  var double sleepAngularThreshold = 0.12,
  var double sleepTimeThreshold = 0.5,
  var double restitutionVelocityThreshold = 0.5,
  var bool autoStep = true,
  super.priority,
}) extends Component with HasWorldRef<World3D> {
  this
    : assert(fixedTimeStep > 0, 'fixedTimeStep must be positive'),
      assert(maxSubSteps >= 1, 'maxSubSteps must be >= 1');

  /// Constant gravitational acceleration (`m/s^2`), `(0, -9.81, 0)` by default.
  final Vector3 gravity = gravity?.clone() ?? Vector3(0.0, -9.81, 0.0);

  double _accumulator = 0.0;

  final List<RigidBody3D> _manualBodies = [];
  final List<Joint3D> _joints = [];
  final List<RigidBody3D> _activeBodies = [];
  final List<_BodySweep> _sweepEntries = [];
  final List<_ContactConstraint3D> _constraints = [];
  Map<int, _WarmImpulse> _warmCache = {};

  final Vector3 _scratchVec = Vector3.zero();
  final Vector3 _scratchTorque = Vector3.zero();

  /// Active constraints registered via [addJoint].
  List<Joint3D> get joints => List.unmodifiable(_joints);

  /// Explicitly registers [body] for standalone simulation outside a mounted
  /// [World3D].
  void addBody(RigidBody3D body) {
    if (!_manualBodies.contains(body)) {
      _manualBodies.add(body);
    }
  }

  /// Removes a manually registered [body].
  void removeBody(RigidBody3D body) {
    _manualBodies.remove(body);
  }

  /// Registers a [Joint3D] constraint between two rigid bodies.
  void addJoint(Joint3D joint) {
    if (!_joints.contains(joint)) {
      _joints.add(joint);
      joint.bodyA.wakeUp();
      joint.bodyB.wakeUp();
    }
  }

  /// Unregisters [joint].
  void removeJoint(Joint3D joint) {
    _joints.remove(joint);
    joint.bodyA.wakeUp();
    joint.bodyB.wakeUp();
  }

  /// Deterministically places, orients, and throws [bodies] (such as polyhedral
  /// dice) from [origin] using [seed].
  void throwDice3D(
    List<RigidBody3D> bodies, {
    required int seed,
    Vector3? origin,
    double spacing = 0.85,
    Vector3? throwVelocity,
    double velocityJitter = 0.6,
    double minSpinSpeed = 10.0,
    double maxSpinSpeed = 22.0,
  }) {
    final rng = SeededRng3D(seed);
    final baseOrigin = origin ?? Vector3(0.0, 3.0, 2.5);
    final baseVel = throwVelocity ?? Vector3(0.0, -1.5, -4.5);
    final halfSpan = (bodies.length - 1) * 0.5 * spacing;

    for (var i = 0; i < bodies.length; i++) {
      final b = bodies[i];
      b.wakeUp();

      final offsetX = i * spacing - halfSpan + rng.rangeDouble(-0.05, 0.05);
      final offsetY = rng.rangeDouble(-0.05, 0.05);
      final offsetZ = rng.rangeDouble(-0.05, 0.05);
      b.bodyPosition.setValues(
        baseOrigin.x + offsetX,
        baseOrigin.y + offsetY,
        baseOrigin.z + offsetZ,
      );

      // Uniform deterministic random orientation on SO(3) (Shoemake method).
      final u1 = rng.nextDouble();
      final u2 = rng.nextDouble() * math.pi * 2.0;
      final u3 = rng.nextDouble() * math.pi * 2.0;
      final s1 = math.sqrt(1.0 - u1);
      final s2 = math.sqrt(u1);
      b.bodyRotation.setValues(
        s1 * math.sin(u2),
        s1 * math.cos(u2),
        s2 * math.sin(u3),
        s2 * math.cos(u3),
      );
      b.updateWorldInertia();

      b.linearVelocity.setValues(
        baseVel.x + rng.rangeDouble(-velocityJitter, velocityJitter),
        baseVel.y +
            rng.rangeDouble(-velocityJitter * 0.5, velocityJitter * 0.5),
        baseVel.z + rng.rangeDouble(-velocityJitter, velocityJitter),
      );

      final uz = rng.rangeDouble(-1.0, 1.0);
      final rHoriz = math.sqrt(math.max(0.0, 1.0 - uz * uz));
      final az = rng.rangeDouble(0.0, math.pi * 2.0);
      final spinMag = rng.rangeDouble(minSpinSpeed, maxSpinSpeed);
      b.angularVelocity.setValues(
        rHoriz * math.cos(az) * spinMag,
        rHoriz * math.sin(az) * spinMag,
        uz * spinMag,
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!autoStep || dt <= 0.0) {
      return;
    }
    _accumulator += dt;
    var subSteps = 0;
    while (_accumulator >= fixedTimeStep && subSteps < maxSubSteps) {
      step(fixedTimeStep);
      _accumulator -= fixedTimeStep;
      subSteps++;
    }
    if (subSteps == maxSubSteps && _accumulator > fixedTimeStep) {
      _accumulator = _accumulator % fixedTimeStep;
    }
  }

  /// Advances the 3D rigid-body simulation by exactly one deterministic step of
  /// [dt] seconds.
  void step(double dt) {
    if (dt <= 0.0) {
      return;
    }
    _collectBodies(_activeBodies);
    if (_activeBodies.isEmpty) {
      return;
    }

    // Keep bodies connected by a joint awake together if either is awake.
    for (var i = 0; i < _joints.length; i++) {
      final j = _joints[i];
      final a = j.bodyA;
      final b = j.bodyB;
      if (a.bodyType == BodyType3D.dynamic &&
          b.bodyType == BodyType3D.dynamic &&
          a.isSleeping != b.isSleeping) {
        a.wakeUp();
        b.wakeUp();
      }
    }

    // 1. Symplectic Euler force & torque integration + implicit Pade damping.
    for (var i = 0; i < _activeBodies.length; i++) {
      final b = _activeBodies[i];
      b.updateWorldInertia();
      if (b.bodyType != BodyType3D.dynamic) {
        b.clearAccumulators();
        continue;
      }
      if (b.isSleeping) {
        b.clearAccumulators();
        continue;
      }

      final invM = b.inverseMass;
      final f = b.accumulatedForce;
      b.linearVelocity.setValues(
        b.linearVelocity.x + (gravity.x + f.x * invM) * dt,
        b.linearVelocity.y + (gravity.y + f.y * invM) * dt,
        b.linearVelocity.z + (gravity.z + f.z * invM) * dt,
      );

      final t = b.accumulatedTorque;
      if (t.x != 0.0 || t.y != 0.0 || t.z != 0.0) {
        b.multiplyWorldInvInertia(t.x, t.y, t.z, _scratchTorque);
        b.angularVelocity.addScaled(_scratchTorque, dt);
      }

      if (b.linearDamping > 0.0) {
        b.linearVelocity.scale(1.0 / (1.0 + dt * b.linearDamping));
      }
      if (b.angularDamping > 0.0) {
        b.angularVelocity.scale(1.0 / (1.0 + dt * b.angularDamping));
      }
      b.clearAccumulators();
    }

    // 2. Broadphase & narrowphase contact constraint build.
    _buildContactConstraints();

    // 3. Prepare joints & warm-start resting contacts.
    for (var i = 0; i < _joints.length; i++) {
      _joints[i].prepare(dt);
    }
    final nextWarmCache = <int, _WarmImpulse>{};
    for (var i = 0; i < _constraints.length; i++) {
      _constraints[i].prepareAndWarmStart(_warmCache, _scratchVec);
    }

    // 4. Sequential Impulse velocity solver iterations.
    for (var iter = 0; iter < velocityIterations; iter++) {
      for (var j = 0; j < _joints.length; j++) {
        _joints[j].solveVelocity(dt);
      }
      for (var c = 0; c < _constraints.length; c++) {
        _constraints[c].solveVelocity(_scratchVec);
      }
    }

    // Store accumulated impulses for next step's warm-starting.
    for (var i = 0; i < _constraints.length; i++) {
      _constraints[i].saveWarmImpulses(nextWarmCache);
    }
    _warmCache = nextWarmCache;

    // 5. Symplectic Euler position & orientation integration.
    for (var i = 0; i < _activeBodies.length; i++) {
      final b = _activeBodies[i];
      if (b.bodyType == BodyType3D.static) {
        continue;
      }
      if (b.bodyType == BodyType3D.dynamic && b.isSleeping) {
        continue;
      }

      final pos = b.bodyPosition;
      final lv = b.linearVelocity;
      if (lv.x != 0.0 || lv.y != 0.0 || lv.z != 0.0) {
        pos.setValues(pos.x + lv.x * dt, pos.y + lv.y * dt, pos.z + lv.z * dt);
      }

      final av = b.angularVelocity;
      final wLen = av.length;
      if (wLen > 1e-9) {
        final angle = wLen * dt;
        final half = 0.5 * angle;
        final s = math.sin(half) / wLen;
        final dqx = av.x * s;
        final dqy = av.y * s;
        final dqz = av.z * s;
        final dqw = math.cos(half);

        final q = b.bodyRotation;
        final qx = q.x;
        final qy = q.y;
        final qz = q.z;
        final qw = q.w;

        final nx = dqw * qx + dqx * qw + dqy * qz - dqz * qy;
        final ny = dqw * qy - dqx * qz + dqy * qw + dqz * qx;
        final nz = dqw * qz + dqx * qy - dqy * qx + dqz * qw;
        final nw = dqw * qw - dqx * qx - dqy * qy - dqz * qz;
        final invNorm = 1.0 / math.sqrt(nx * nx + ny * ny + nz * nz + nw * nw);
        q.setValues(nx * invNorm, ny * invNorm, nz * invNorm, nw * invNorm);
        b.updateWorldInertia();
      }
    }

    // 6. Split-impulse / NGS position correction iterations.
    for (var iter = 0; iter < positionIterations; iter++) {
      for (var j = 0; j < _joints.length; j++) {
        _joints[j].solvePosition();
      }
      for (var c = 0; c < _constraints.length; c++) {
        _constraints[c].solvePosition(_scratchVec);
      }
    }

    // 7. Sleep timer evaluation.
    final linThresh2 = sleepLinearThreshold * sleepLinearThreshold;
    final angThresh2 = sleepAngularThreshold * sleepAngularThreshold;
    for (var i = 0; i < _activeBodies.length; i++) {
      final b = _activeBodies[i];
      if (b.bodyType != BodyType3D.dynamic || !b.canSleep || b.isSleeping) {
        continue;
      }
      if (b.linearVelocity.length2 <= linThresh2 &&
          b.angularVelocity.length2 <= angThresh2) {
        b.sleepTimer += dt;
        if (b.sleepTimer >= sleepTimeThreshold) {
          b.putToSleep();
        }
      } else {
        b.sleepTimer = 0.0;
      }
    }
  }

  void _collectBodies(List<RigidBody3D> out) {
    out.clear();
    final seen = <RigidBody3D>{};

    void addUnique(RigidBody3D b) {
      if (seen.add(b)) {
        out.add(b);
      }
    }

    for (var i = 0; i < _manualBodies.length; i++) {
      addUnique(_manualBodies[i]);
    }

    final root = parent;
    if (root != null) {
      void visit(Component comp) {
        if (comp is RigidBody3D) {
          addUnique(comp);
        }
        for (final child in comp.children) {
          visit(child);
        }
      }

      visit(root);
    }

    // Deterministic ordering by `deterministicId`.
    out.sort((a, b) => a.deterministicId.compareTo(b.deterministicId));
  }

  bool _jointBlocksCollision(RigidBody3D a, RigidBody3D b) {
    for (var i = 0; i < _joints.length; i++) {
      final j = _joints[i];
      if (!j.collideConnected &&
          ((identical(j.bodyA, a) && identical(j.bodyB, b)) ||
              (identical(j.bodyA, b) && identical(j.bodyB, a)))) {
        return true;
      }
    }
    return false;
  }

  void _buildContactConstraints() {
    _constraints.clear();
    _sweepEntries.clear();

    for (var i = 0; i < _activeBodies.length; i++) {
      final b = _activeBodies[i];
      final box = b.bodyWorldAabb;
      _sweepEntries.add(
        _BodySweep(
          body: b,
          minX: box.min.x,
          minY: box.min.y,
          minZ: box.min.z,
          maxX: box.max.x,
          maxY: box.max.y,
          maxZ: box.max.z,
        ),
      );
    }

    _sweepEntries.sort((a, b) {
      final cmp = a.minX.compareTo(b.minX);
      return cmp != 0
          ? cmp
          : a.body.deterministicId.compareTo(b.body.deterministicId);
    });

    final wakeVelThresh2 =
        (sleepLinearThreshold * 2.0) * (sleepLinearThreshold * 2.0);

    for (var i = 0; i < _sweepEntries.length; i++) {
      final sA = _sweepEntries[i];
      final maxX = sA.maxX;
      for (var j = i + 1; j < _sweepEntries.length; j++) {
        final sB = _sweepEntries[j];
        if (sB.minX > maxX) {
          break;
        }
        if (sA.maxY < sB.minY ||
            sA.minY > sB.maxY ||
            sA.maxZ < sB.minZ ||
            sA.minZ > sB.maxZ) {
          continue;
        }

        // Canonical deterministic order `first.deterministicId < second`.
        final swap = sA.body.deterministicId > sB.body.deterministicId;
        final bodyA = swap ? sB.body : sA.body;
        final bodyB = swap ? sA.body : sB.body;

        if (!bodyA.canCollideWith(bodyB)) {
          continue;
        }
        final aSleep = bodyA.bodyType != BodyType3D.dynamic || bodyA.isSleeping;
        final bSleep = bodyB.bodyType != BodyType3D.dynamic || bodyB.isSleeping;
        if (aSleep && bSleep) {
          continue;
        }
        if (_jointBlocksCollision(bodyA, bodyB)) {
          continue;
        }

        final manifold = Narrowphase3D.test(
          bodyA.shape,
          bodyA.bodyWorldMatrix,
          bodyB.shape,
          bodyB.bodyWorldMatrix,
        );
        if (manifold == null) {
          continue;
        }

        // Wake sleeping partner if moving fast enough on impact.
        if (bodyA.bodyType == BodyType3D.dynamic &&
            bodyB.bodyType == BodyType3D.dynamic &&
            bodyA.isSleeping != bodyB.isSleeping) {
          final dvx = bodyB.linearVelocity.x - bodyA.linearVelocity.x;
          final dvy = bodyB.linearVelocity.y - bodyA.linearVelocity.y;
          final dvz = bodyB.linearVelocity.z - bodyA.linearVelocity.z;
          if (dvx * dvx + dvy * dvy + dvz * dvz > wakeVelThresh2 ||
              manifold.penetrationDepth > 0.01) {
            bodyA.wakeUp();
            bodyB.wakeUp();
          }
        }

        _constraints.add(
          _ContactConstraint3D(
            bodyA: bodyA,
            bodyB: bodyB,
            manifold: manifold,
            restitutionThreshold: restitutionVelocityThreshold,
          ),
        );
      }
    }
  }
}

class _BodySweep({
  required final RigidBody3D body,
  required final double minX,
  required final double minY,
  required final double minZ,
  required final double maxX,
  required final double maxY,
  required final double maxZ,
});

class _WarmImpulse(this.jn, this.jt1, this.jt2) {
  final double jn;
  final double jt1;
  final double jt2;
}

class _ContactPointState({
  required final int cacheKey,
  required final Vector3 localOffsetA,
  required final Vector3 localOffsetB,
  required final Vector3 rA,
  required final Vector3 rB,
  required final double depth,
}) {
  double effMassN = 0.0;
  double effMassT1 = 0.0;
  double effMassT2 = 0.0;
  double bounceTargetVn = 0.0;

  double jn = 0.0;
  double jt1 = 0.0;
  double jt2 = 0.0;
}

class _ContactConstraint3D({
  required final RigidBody3D bodyA,
  required final RigidBody3D bodyB,
  required final CollisionManifold3D manifold,
  required final double restitutionThreshold,
}) {
  this {
    if (normal.x.abs() < 0.9) {
      t1.setValues(0.0, -normal.z, normal.y);
    } else {
      t1.setValues(-normal.z, 0.0, normal.x);
    }
    t1.normalize();
    t2.setValues(
      normal.y * t1.z - normal.z * t1.y,
      normal.z * t1.x - normal.x * t1.z,
      normal.x * t1.y - normal.y * t1.x,
    );

    final posA = bodyA.bodyPosition;
    final posB = bodyB.bodyPosition;

    final pairHash = Object.hash(bodyA.deterministicId, bodyB.deterministicId);
    final contacts = manifold.contacts;
    for (var idx = 0; idx < contacts.length; idx++) {
      final cp = contacts[idx];
      final rA = cp.pointA - posA;
      final rB = cp.pointB - posB;
      final locA = Vector3.zero();
      final locB = Vector3.zero();
      _unrotateByQuat(bodyA.bodyRotation, rA, locA);
      _unrotateByQuat(bodyB.bodyRotation, rB, locB);
      points.add(
        _ContactPointState(
          cacheKey: Object.hash(pairHash, idx),
          localOffsetA: locA,
          localOffsetB: locB,
          rA: rA,
          rB: rB,
          depth: cp.penetrationDepth,
        ),
      );
    }
  }

  final Vector3 normal = manifold.normal.clone();
  final Vector3 t1 = Vector3.zero();
  final Vector3 t2 = Vector3.zero();
  final double restitution = math.max(bodyA.restitution, bodyB.restitution);
  final double friction = math.sqrt(
    math.max(0.0, bodyA.friction * bodyB.friction),
  );
  final List<_ContactPointState> points = [];

  void prepareAndWarmStart(
    Map<int, _WarmImpulse> prevCache,
    Vector3 scratch,
  ) {
    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      p.effMassN = _axisMass(p.rA, p.rB, normal, scratch);
      p.effMassT1 = _axisMass(p.rA, p.rB, t1, scratch);
      p.effMassT2 = _axisMass(p.rA, p.rB, t2, scratch);

      // Measure pre-impact normal velocity BEFORE warm-starting!
      final vnPre = _relVelDot(p.rA, p.rB, normal);
      if (vnPre < -restitutionThreshold && restitution > 0.0) {
        p.bounceTargetVn = -restitution * vnPre;
      } else {
        p.bounceTargetVn = 0.0;
        // Warm-start resting contacts only so bounces stay exact.
        final warm = prevCache[p.cacheKey];
        if (warm != null) {
          p.jn = warm.jn * 0.85;
          p.jt1 = warm.jt1 * 0.85;
          p.jt2 = warm.jt2 * 0.85;
          final ix = normal.x * p.jn + t1.x * p.jt1 + t2.x * p.jt2;
          final iy = normal.y * p.jn + t1.y * p.jt1 + t2.y * p.jt2;
          final iz = normal.z * p.jn + t1.z * p.jt1 + t2.z * p.jt2;
          _applyImpulse(p.rA, p.rB, ix, iy, iz, scratch);
        }
      }
    }
  }

  void solveVelocity(Vector3 scratch) {
    // Tangent friction pass first, then non-penetration normal pass (with
    // isotropic Coulomb cone clamping).
    for (var i = 0; i < points.length; i++) {
      final p = points[i];

      // 1. Normal impulse (`jn >= 0`).
      final vn = _relVelDot(p.rA, p.rB, normal);
      var dJn = p.effMassN * (p.bounceTargetVn - vn);
      final prevJn = p.jn;
      p.jn = math.max(0.0, prevJn + dJn);
      dJn = p.jn - prevJn;
      if (dJn.abs() > 1e-14) {
        _applyImpulse(
          p.rA,
          p.rB,
          normal.x * dJn,
          normal.y * dJn,
          normal.z * dJn,
          scratch,
        );
      }

      // 2. 2-tangent isotropic Coulomb friction (`||(jt1, jt2)|| <= mu * jn`).
      if (friction > 0.0 && p.jn > 0.0) {
        final vt1 = _relVelDot(p.rA, p.rB, t1);
        final vt2 = _relVelDot(p.rA, p.rB, t2);
        final candT1 = p.jt1 - p.effMassT1 * vt1;
        final candT2 = p.jt2 - p.effMassT2 * vt2;
        final maxFriction = friction * p.jn;
        final mag2 = candT1 * candT1 + candT2 * candT2;

        double nextT1;
        double nextT2;
        if (mag2 > maxFriction * maxFriction && mag2 > 1e-24) {
          final scale = maxFriction / math.sqrt(mag2);
          nextT1 = candT1 * scale;
          nextT2 = candT2 * scale;
        } else {
          nextT1 = candT1;
          nextT2 = candT2;
        }

        final dJt1 = nextT1 - p.jt1;
        final dJt2 = nextT2 - p.jt2;
        p.jt1 = nextT1;
        p.jt2 = nextT2;
        if (dJt1.abs() > 1e-14 || dJt2.abs() > 1e-14) {
          _applyImpulse(
            p.rA,
            p.rB,
            t1.x * dJt1 + t2.x * dJt2,
            t1.y * dJt1 + t2.y * dJt2,
            t1.z * dJt1 + t2.z * dJt2,
            scratch,
          );
        }
      }
    }
  }

  void solvePosition(Vector3 scratch) {
    const slop = 0.004;
    final baumgarte = 0.25 / math.max(1, points.length);
    final rA = Vector3.zero();
    final rB = Vector3.zero();

    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      // Re-evaluate world contact witnesses from updated poses.
      _rotateByQuat(bodyA.bodyRotation, p.localOffsetA, rA);
      _rotateByQuat(bodyB.bodyRotation, p.localOffsetB, rB);
      final wAx = bodyA.bodyPosition.x + rA.x;
      final wAy = bodyA.bodyPosition.y + rA.y;
      final wAz = bodyA.bodyPosition.z + rA.z;
      final wBx = bodyB.bodyPosition.x + rB.x;
      final wBy = bodyB.bodyPosition.y + rB.y;
      final wBz = bodyB.bodyPosition.z + rB.z;

      // Current penetration along `normal` (`(wA - wB) . normal > 0`).
      final pen =
          (wAx - wBx) * normal.x +
          (wAy - wBy) * normal.y +
          (wAz - wBz) * normal.z;
      final corr = math.min(0.15, math.max(0.0, pen - slop) * baumgarte);
      if (corr <= 1e-7) {
        continue;
      }

      final massN = _axisMass(rA, rB, normal, scratch);
      if (massN <= 0.0) {
        continue;
      }
      final pImpulse = massN * corr;
      final px = normal.x * pImpulse;
      final py = normal.y * pImpulse;
      final pz = normal.z * pImpulse;

      if (bodyA.inverseMass > 0.0 && !bodyA.isSleeping) {
        final posA = bodyA.bodyPosition;
        posA.setValues(
          posA.x - px * bodyA.inverseMass,
          posA.y - py * bodyA.inverseMass,
          posA.z - pz * bodyA.inverseMass,
        );
        final tx = rA.y * pz - rA.z * py;
        final ty = rA.z * px - rA.x * pz;
        final tz = rA.x * py - rA.y * px;
        bodyA.multiplyWorldInvInertia(-tx, -ty, -tz, scratch);
        _applyDeltaQuat(bodyA, scratch);
      }
      if (bodyB.inverseMass > 0.0 && !bodyB.isSleeping) {
        final posB = bodyB.bodyPosition;
        posB.setValues(
          posB.x + px * bodyB.inverseMass,
          posB.y + py * bodyB.inverseMass,
          posB.z + pz * bodyB.inverseMass,
        );
        final tx = rB.y * pz - rB.z * py;
        final ty = rB.z * px - rB.x * pz;
        final tz = rB.x * py - rB.y * px;
        bodyB.multiplyWorldInvInertia(tx, ty, tz, scratch);
        _applyDeltaQuat(bodyB, scratch);
      }
    }
  }

  void saveWarmImpulses(Map<int, _WarmImpulse> outCache) {
    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      if (p.jn > 1e-9 || p.jt1.abs() > 1e-9 || p.jt2.abs() > 1e-9) {
        outCache[p.cacheKey] = _WarmImpulse(p.jn, p.jt1, p.jt2);
      }
    }
  }

  double _axisMass(Vector3 rA, Vector3 rB, Vector3 axis, Vector3 scratch) {
    var k = bodyA.inverseMass + bodyB.inverseMass;
    if (bodyA.inverseMass > 0.0) {
      final cx = rA.y * axis.z - rA.z * axis.y;
      final cy = rA.z * axis.x - rA.x * axis.z;
      final cz = rA.x * axis.y - rA.y * axis.x;
      bodyA.multiplyWorldInvInertia(cx, cy, cz, scratch);
      k += cx * scratch.x + cy * scratch.y + cz * scratch.z;
    }
    if (bodyB.inverseMass > 0.0) {
      final cx = rB.y * axis.z - rB.z * axis.y;
      final cy = rB.z * axis.x - rB.x * axis.z;
      final cz = rB.x * axis.y - rB.y * axis.x;
      bodyB.multiplyWorldInvInertia(cx, cy, cz, scratch);
      k += cx * scratch.x + cy * scratch.y + cz * scratch.z;
    }
    return k > 1e-12 ? 1.0 / k : 0.0;
  }

  double _relVelDot(Vector3 rA, Vector3 rB, Vector3 axis) {
    final vAx =
        bodyA.linearVelocity.x +
        (bodyA.angularVelocity.y * rA.z - bodyA.angularVelocity.z * rA.y);
    final vAy =
        bodyA.linearVelocity.y +
        (bodyA.angularVelocity.z * rA.x - bodyA.angularVelocity.x * rA.z);
    final vAz =
        bodyA.linearVelocity.z +
        (bodyA.angularVelocity.x * rA.y - bodyA.angularVelocity.y * rA.x);

    final vBx =
        bodyB.linearVelocity.x +
        (bodyB.angularVelocity.y * rB.z - bodyB.angularVelocity.z * rB.y);
    final vBy =
        bodyB.linearVelocity.y +
        (bodyB.angularVelocity.z * rB.x - bodyB.angularVelocity.x * rB.z);
    final vBz =
        bodyB.linearVelocity.z +
        (bodyB.angularVelocity.x * rB.y - bodyB.angularVelocity.y * rB.x);

    return (vBx - vAx) * axis.x + (vBy - vAy) * axis.y + (vBz - vAz) * axis.z;
  }

  void _applyImpulse(
    Vector3 rA,
    Vector3 rB,
    double px,
    double py,
    double pz,
    Vector3 scratch,
  ) {
    if (bodyA.inverseMass > 0.0 && !bodyA.isSleeping) {
      bodyA.linearVelocity.setValues(
        bodyA.linearVelocity.x - px * bodyA.inverseMass,
        bodyA.linearVelocity.y - py * bodyA.inverseMass,
        bodyA.linearVelocity.z - pz * bodyA.inverseMass,
      );
      final tx = rA.y * pz - rA.z * py;
      final ty = rA.z * px - rA.x * pz;
      final tz = rA.x * py - rA.y * px;
      bodyA.multiplyWorldInvInertia(tx, ty, tz, scratch);
      bodyA.angularVelocity.sub(scratch);
    }
    if (bodyB.inverseMass > 0.0 && !bodyB.isSleeping) {
      bodyB.linearVelocity.setValues(
        bodyB.linearVelocity.x + px * bodyB.inverseMass,
        bodyB.linearVelocity.y + py * bodyB.inverseMass,
        bodyB.linearVelocity.z + pz * bodyB.inverseMass,
      );
      final tx = rB.y * pz - rB.z * py;
      final ty = rB.z * px - rB.x * pz;
      final tz = rB.x * py - rB.y * px;
      bodyB.multiplyWorldInvInertia(tx, ty, tz, scratch);
      bodyB.angularVelocity.add(scratch);
    }
  }

  static void _applyDeltaQuat(RigidBody3D body, Vector3 dTheta) {
    final angle = dTheta.length;
    if (angle <= 1e-8) {
      return;
    }
    final half = 0.5 * angle;
    final s = math.sin(half) / angle;
    final dqx = dTheta.x * s;
    final dqy = dTheta.y * s;
    final dqz = dTheta.z * s;
    final dqw = math.cos(half);

    final q = body.bodyRotation;
    final qx = q.x;
    final qy = q.y;
    final qz = q.z;
    final qw = q.w;

    final nx = dqw * qx + dqx * qw + dqy * qz - dqz * qy;
    final ny = dqw * qy - dqx * qz + dqy * qw + dqz * qx;
    final nz = dqw * qz + dqx * qy - dqy * qx + dqz * qw;
    final nw = dqw * qw - dqx * qx - dqy * qy - dqz * qz;
    final invNorm = 1.0 / math.sqrt(nx * nx + ny * ny + nz * nz + nw * nw);
    q.setValues(nx * invNorm, ny * invNorm, nz * invNorm, nw * invNorm);
    body.updateWorldInertia();
  }

  static void _rotateByQuat(Quaternion q, Vector3 v, Vector3 out) {
    final qx = q.x;
    final qy = q.y;
    final qz = q.z;
    final qw = q.w;
    final tx = 2.0 * (qy * v.z - qz * v.y);
    final ty = 2.0 * (qz * v.x - qx * v.z);
    final tz = 2.0 * (qx * v.y - qy * v.x);
    out.setValues(
      v.x + qw * tx + (qy * tz - qz * ty),
      v.y + qw * ty + (qz * tx - qx * tz),
      v.z + qw * tz + (qx * ty - qy * tx),
    );
  }

  static void _unrotateByQuat(Quaternion q, Vector3 v, Vector3 out) {
    final qx = -q.x;
    final qy = -q.y;
    final qz = -q.z;
    final qw = q.w;
    final tx = 2.0 * (qy * v.z - qz * v.y);
    final ty = 2.0 * (qz * v.x - qx * v.z);
    final tz = 2.0 * (qx * v.y - qy * v.x);
    out.setValues(
      v.x + qw * tx + (qy * tz - qz * ty),
      v.y + qw * ty + (qz * tx - qx * tz),
      v.z + qw * tz + (qx * ty - qy * tx),
    );
  }
}
