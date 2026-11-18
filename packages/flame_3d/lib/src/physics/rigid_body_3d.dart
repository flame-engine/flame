import 'dart:math' as math;

import 'package:flame_3d/collisions.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/game.dart' show NotifyingQuaternion, NotifyingVector3;

/// Simulation mobility mode of a [RigidBody3D].
enum BodyType3D() {
  /// Simulated under gravity, forces, impulses, contacts, and joints.
  dynamic,

  /// Driven kinematically by velocity/code; infinite mass in collisions.
  kinematic,

  /// Immovable world geometry; zero velocity and infinite mass.
  static,
}

/// A 3D rigid body component simulated by `PhysicsWorld3D`.
///
/// Can be added either as a child of an existing [Component3D] (such as a
/// [MeshComponent], automatically synchronizing its parent's `position` and
/// `rotation`) or standalone directly inside a `World3D`.
class RigidBody3D({
  required Shape3D shape,
  BodyType3D bodyType = BodyType3D.dynamic,
  double mass = 1.0,
  var double restitution = 0.0,
  var double friction = 0.5,
  var double linearDamping = 0.01,
  var double angularDamping = 0.05,
  Vector3? linearVelocity,
  Vector3? angularVelocity,
  var bool canSleep = true,
  var bool isSleeping = false,
  var int collisionLayer = 1,
  var int collisionMask = 0xFFFFFFFF,
  var bool syncParent = true,
  super.position,
  super.scale,
  super.rotation,
  super.children,
}) extends Component3D {
  this : assert(mass >= 0, 'mass must be non-negative') {
    _recomputeMassProperties();
  }

  static int _nextDeterministicId = 1;

  /// Monotonic creation identifier used for deterministic broadphase ordering.
  final int deterministicId = _nextDeterministicId++;

  BodyType3D _bodyType = bodyType;

  /// Mobility classification (`dynamic`, `kinematic`, or `static`).
  BodyType3D get bodyType => _bodyType;
  set bodyType(BodyType3D value) {
    if (value == _bodyType) {
      return;
    }
    _bodyType = value;
    if (value != BodyType3D.dynamic) {
      isSleeping = false;
      sleepTimer = 0.0;
      if (value == BodyType3D.static) {
        linearVelocity.setZero();
        angularVelocity.setZero();
      }
    }
    _recomputeMassProperties();
  }

  Shape3D _shape = shape;

  /// Collision and inertia shape of this body.
  Shape3D get shape => _shape;
  set shape(Shape3D value) {
    if (identical(value, _shape)) {
      return;
    }
    _shape = value;
    _recomputeMassProperties();
    markAabbDirty();
  }

  double _mass = mass;

  /// Mass in kilograms (used when [bodyType] is [BodyType3D.dynamic]).
  double get mass => _mass;
  set mass(double value) {
    assert(value >= 0, 'mass must be non-negative');
    if (value == _mass) {
      return;
    }
    _mass = value;
    _recomputeMassProperties();
  }

  /// World-space linear velocity (`m/s`).
  final Vector3 linearVelocity = linearVelocity?.clone() ?? Vector3.zero();

  /// World-space angular velocity (`rad/s`).
  final Vector3 angularVelocity = angularVelocity?.clone() ?? Vector3.zero();

  /// Accumulated sleep timer in seconds managed by `PhysicsWorld3D`.
  double sleepTimer = 0.0;

  double _inverseMass = 0.0;
  final Vector3 _localInvInertia = Vector3.zero();

  /// Inverse mass (`0` for `static` and `kinematic` bodies).
  double get inverseMass => _inverseMass;

  /// Local-space inverse inertia diagonal.
  Vector3 get localInverseInertia => _localInvInertia;

  /// World-space `3x3` inverse inertia tensor `R * I_local^-1 * R^T`.
  final Matrix3 worldInvInertia = Matrix3.zero();

  final Vector3 _forceAccum = Vector3.zero();
  final Vector3 _torqueAccum = Vector3.zero();
  final Matrix4 _bodyWorldMatrix = Matrix4.identity();
  final Aabb3 _worldAabb = Aabb3();
  final Aabb3 _localAabb = Aabb3();
  final Vector3 _scratchR = Vector3.zero();
  final Vector3 _scratchCross = Vector3.zero();

  /// Accumulated world force for the upcoming physics step.
  Vector3 get accumulatedForce => _forceAccum;

  /// Accumulated world torque for the upcoming physics step.
  Vector3 get accumulatedTorque => _torqueAccum;

  /// Clears accumulated forces and torques at the end of force integration.
  void clearAccumulators() {
    _forceAccum.setZero();
    _torqueAccum.setZero();
  }

  /// The [Component3D] whose transform this rigid body drives: its parent
  /// [Component3D] when [syncParent] is `true` and attached as a child, or
  /// `this` when standalone.
  Component3D get hostComponent {
    if (syncParent) {
      final p = parent;
      if (p is Component3D) {
        return p;
      }
    }
    return this;
  }

  /// World/parent position of [hostComponent].
  NotifyingVector3 get bodyPosition => hostComponent.position;

  /// Orientation quaternion of [hostComponent].
  NotifyingQuaternion get bodyRotation => hostComponent.rotation;

  /// Current world transform matrix of this body's shape.
  Matrix4 get bodyWorldMatrix {
    final host = hostComponent;
    _bodyWorldMatrix.setFromTranslationRotationScale(
      host.position,
      host.rotation,
      host.scale,
    );
    return _bodyWorldMatrix;
  }

  /// Computes and returns the current world-space AABB of [shape].
  Aabb3 get bodyWorldAabb {
    _shape.computeWorldAabb(bodyWorldMatrix, _worldAabb);
    return _worldAabb;
  }

  /// Recomputes [worldInvInertia] (`R * diag(localInvInertia) * R^T`) from the
  /// current [bodyRotation] with zero heap allocations.
  void updateWorldInertia() {
    if (_bodyType != BodyType3D.dynamic || _inverseMass <= 0.0) {
      worldInvInertia.setZero();
      return;
    }
    final q = bodyRotation;
    final x = q.x;
    final y = q.y;
    final z = q.z;
    final w = q.w;
    final x2 = x + x;
    final y2 = y + y;
    final z2 = z + z;
    final xx = x * x2;
    final xy = x * y2;
    final xz = x * z2;
    final yy = y * y2;
    final yz = y * z2;
    final zz = z * z2;
    final wx = w * x2;
    final wy = w * y2;
    final wz = w * z2;

    final r00 = 1.0 - (yy + zz);
    final r10 = xy + wz;
    final r20 = xz - wy;
    final r01 = xy - wz;
    final r11 = 1.0 - (xx + zz);
    final r21 = yz + wx;
    final r02 = xz + wy;
    final r12 = yz - wx;
    final r22 = 1.0 - (xx + yy);

    final ix = _localInvInertia.x;
    final iy = _localInvInertia.y;
    final iz = _localInvInertia.z;

    final m00 = r00 * r00 * ix + r01 * r01 * iy + r02 * r02 * iz;
    final m01 = r00 * r10 * ix + r01 * r11 * iy + r02 * r12 * iz;
    final m02 = r00 * r20 * ix + r01 * r21 * iy + r02 * r22 * iz;
    final m11 = r10 * r10 * ix + r11 * r11 * iy + r12 * r12 * iz;
    final m12 = r10 * r20 * ix + r11 * r21 * iy + r12 * r22 * iz;
    final m22 = r20 * r20 * ix + r21 * r21 * iy + r22 * r22 * iz;

    final out = worldInvInertia.storage;
    out[0] = m00;
    out[1] = m01;
    out[2] = m02;
    out[3] = m01;
    out[4] = m11;
    out[5] = m12;
    out[6] = m02;
    out[7] = m12;
    out[8] = m22;
  }

  /// Multiplies [worldInvInertia] by `(vx, vy, vz)` and writes into [out].
  void multiplyWorldInvInertia(
    double vx,
    double vy,
    double vz,
    Vector3 out,
  ) {
    final s = worldInvInertia.storage;
    out.setValues(
      s[0] * vx + s[3] * vy + s[6] * vz,
      s[1] * vx + s[4] * vy + s[7] * vz,
      s[2] * vx + s[5] * vy + s[8] * vz,
    );
  }

  /// Wakes this body from sleep.
  void wakeUp() {
    if (_bodyType == BodyType3D.dynamic) {
      isSleeping = false;
      sleepTimer = 0.0;
    }
  }

  /// Immediately puts this body to sleep and zeroes velocities and forces.
  void putToSleep() {
    if (_bodyType == BodyType3D.dynamic && canSleep) {
      isSleeping = true;
      linearVelocity.setZero();
      angularVelocity.setZero();
      _forceAccum.setZero();
      _torqueAccum.setZero();
    }
  }

  /// Applies an instantaneous linear [impulse] (`N*s`), optionally at
  /// [worldPoint] (generating torque `(worldPoint - bodyPosition) x impulse`).
  void applyImpulse(Vector3 impulse, {Vector3? worldPoint}) {
    if (_bodyType != BodyType3D.dynamic || _inverseMass <= 0.0) {
      return;
    }
    wakeUp();
    linearVelocity.addScaled(impulse, _inverseMass);
    if (worldPoint != null) {
      final pos = bodyPosition;
      _scratchR.setValues(
        worldPoint.x - pos.x,
        worldPoint.y - pos.y,
        worldPoint.z - pos.z,
      );
      _cross(_scratchR, impulse, _scratchCross);
      updateWorldInertia();
      multiplyWorldInvInertia(
        _scratchCross.x,
        _scratchCross.y,
        _scratchCross.z,
        _scratchR,
      );
      angularVelocity.add(_scratchR);
    }
  }

  /// Applies a continuous [force] (`N`) integrated on the next step, optionally
  /// at [worldPoint].
  void applyForce(Vector3 force, {Vector3? worldPoint}) {
    if (_bodyType != BodyType3D.dynamic || _inverseMass <= 0.0) {
      return;
    }
    wakeUp();
    _forceAccum.add(force);
    if (worldPoint != null) {
      final pos = bodyPosition;
      _scratchR.setValues(
        worldPoint.x - pos.x,
        worldPoint.y - pos.y,
        worldPoint.z - pos.z,
      );
      _cross(_scratchR, force, _scratchCross);
      _torqueAccum.add(_scratchCross);
    }
  }

  /// Applies an instantaneous angular impulse [torque] (`N*m*s`).
  void applyTorqueImpulse(Vector3 torque) {
    if (_bodyType != BodyType3D.dynamic || _inverseMass <= 0.0) {
      return;
    }
    wakeUp();
    updateWorldInertia();
    multiplyWorldInvInertia(torque.x, torque.y, torque.z, _scratchR);
    angularVelocity.add(_scratchR);
  }

  /// Applies a continuous [torque] (`N*m`) integrated on the next step.
  void applyTorque(Vector3 torque) {
    if (_bodyType != BodyType3D.dynamic || _inverseMass <= 0.0) {
      return;
    }
    wakeUp();
    _torqueAccum.add(torque);
  }

  /// Applies a cross-platform deterministic launch velocity and angular spin
  /// derived from [seed] via [SeededRng3D].
  void applySeededSpinImpulse({
    required int seed,
    double linearSpeed = 5.0,
    Vector3? baseDirection,
    double directionSpreadRad = 0.2,
    double minSpinSpeed = 8.0,
    double maxSpinSpeed = 18.0,
  }) {
    if (_bodyType != BodyType3D.dynamic || _inverseMass <= 0.0) {
      return;
    }
    final rng = SeededRng3D(seed);
    wakeUp();

    final dir = baseDirection != null && baseDirection.length2 > 1e-12
        ? baseDirection.normalized()
        : Vector3(0.0, 0.35, -1.0).normalized();

    // Deterministic spherical perturbation within `directionSpreadRad`.
    final theta = rng.rangeDouble(0.0, math.pi * 2.0);
    final phi = rng.rangeDouble(0.0, directionSpreadRad);
    final perp1 = dir.x.abs() < 0.9
        ? Vector3(0.0, -dir.z, dir.y).normalized()
        : Vector3(-dir.z, 0.0, dir.x).normalized();
    final perp2 = dir.cross(perp1);

    final launchDir =
        (dir * math.cos(phi) +
                perp1 * (math.sin(phi) * math.cos(theta)) +
                perp2 * (math.sin(phi) * math.sin(theta)))
            .normalized();

    linearVelocity
      ..setFrom(launchDir)
      ..scale(linearSpeed);

    // Uniform random unit spin axis on S^2.
    final uz = rng.rangeDouble(-1.0, 1.0);
    final rHoriz = math.sqrt(math.max(0.0, 1.0 - uz * uz));
    final az = rng.rangeDouble(0.0, math.pi * 2.0);
    final spinMag = rng.rangeDouble(minSpinSpeed, maxSpinSpeed);
    angularVelocity.setValues(
      rHoriz * math.cos(az) * spinMag,
      rHoriz * math.sin(az) * spinMag,
      uz * spinMag,
    );
  }

  /// Returns whether 32-bit layer/mask filtering permits contact with [other].
  bool canCollideWith(RigidBody3D other) {
    if (identical(this, other) ||
        identical(hostComponent, other.hostComponent)) {
      return false;
    }
    if (_bodyType != BodyType3D.dynamic &&
        other._bodyType != BodyType3D.dynamic) {
      return false;
    }
    return (collisionLayer & other.collisionMask) != 0 &&
        (other.collisionLayer & collisionMask) != 0;
  }

  @override
  Aabb3? computeLocalAabb() => _shape.computeLocalAabb(out: _localAabb);

  void _recomputeMassProperties() {
    if (_bodyType != BodyType3D.dynamic || _mass <= 0.0) {
      _inverseMass = 0.0;
      _localInvInertia.setZero();
      worldInvInertia.setZero();
      return;
    }
    _inverseMass = 1.0 / _mass;
    final diag = _shape.computeLocalInertiaDiagonal(_mass);
    _localInvInertia.setValues(
      diag.x > 1e-12 ? 1.0 / diag.x : 0.0,
      diag.y > 1e-12 ? 1.0 / diag.y : 0.0,
      diag.z > 1e-12 ? 1.0 / diag.z : 0.0,
    );
    updateWorldInertia();
  }

  static void _cross(Vector3 a, Vector3 b, Vector3 out) {
    out.setValues(
      a.y * b.z - a.z * b.y,
      a.z * b.x - a.x * b.z,
      a.x * b.y - a.y * b.x,
    );
  }
}
