import 'dart:math' as math;

import 'package:flame_3d/core.dart';
import 'package:flame_3d/physics.dart';

/// Base class for 3D constraints connecting two [RigidBody3D] instances inside
/// a [PhysicsWorld3D].
abstract class Joint3D({
  required final RigidBody3D bodyA,
  required final RigidBody3D bodyB,
  final bool collideConnected = false,
}) {
  /// Precomputes lever arms and effective mass matrices at the start of a step.
  void prepare(double dt);

  /// Iteratively enforces velocity-level constraint equations.
  void solveVelocity(double dt);

  /// Iteratively corrects residual positional/angular drift.
  void solvePosition();
}

/// Fixed-rod or spring-damper 1-DOF distance constraint between `localAnchorA`
/// on [bodyA] and `localAnchorB` on [bodyB].
class DistanceJoint3D({
  required super.bodyA,
  required super.bodyB,
  Vector3? localAnchorA,
  Vector3? localAnchorB,
  double? length,
  var double frequencyHz = 0.0,
  var double dampingRatio = 0.7,
  super.collideConnected,
}) extends Joint3D {
  this {
    if (length != null) {
      this.length = math.max(0.0, length);
    } else {
      final rotA = Vector3.zero();
      final rotB = Vector3.zero();
      _rotateQuat(bodyA.bodyRotation, this.localAnchorA, rotA);
      _rotateQuat(bodyB.bodyRotation, this.localAnchorB, rotB);
      final pA = bodyA.bodyPosition + rotA;
      final pB = bodyB.bodyPosition + rotB;
      this.length = pA.distanceTo(pB);
    }
  }

  /// Anchor point in [bodyA]'s local space.
  final Vector3 localAnchorA = localAnchorA?.clone() ?? Vector3.zero();

  /// Anchor point in [bodyB]'s local space.
  final Vector3 localAnchorB = localAnchorB?.clone() ?? Vector3.zero();

  /// Target rest length in world units.
  late double length;

  final Vector3 _rA = Vector3.zero();
  final Vector3 _rB = Vector3.zero();
  final Vector3 _u = Vector3.zero();
  final Vector3 _scratch = Vector3.zero();
  double _effMass = 0.0;
  double _bias = 0.0;
  double _gamma = 0.0;
  double _accumImpulse = 0.0;

  @override
  void prepare(double dt) {
    _rotateQuat(bodyA.bodyRotation, localAnchorA, _rA);
    _rotateQuat(bodyB.bodyRotation, localAnchorB, _rB);

    final dx = (bodyB.bodyPosition.x + _rB.x) - (bodyA.bodyPosition.x + _rA.x);
    final dy = (bodyB.bodyPosition.y + _rB.y) - (bodyA.bodyPosition.y + _rA.y);
    final dz = (bodyB.bodyPosition.z + _rB.z) - (bodyA.bodyPosition.z + _rA.z);
    final curLen = math.sqrt(dx * dx + dy * dy + dz * dz);
    if (curLen > 1e-7) {
      _u.setValues(dx / curLen, dy / curLen, dz / curLen);
    } else {
      _u.setValues(0.0, 1.0, 0.0);
    }

    final k = _computeLinearAxisK(bodyA, _rA, bodyB, _rB, _u, _scratch);
    final rawMass = k > 1e-12 ? 1.0 / k : 0.0;
    final c = curLen - length;

    if (frequencyHz > 0.0 && rawMass > 0.0 && dt > 0.0) {
      final omega = 2.0 * math.pi * frequencyHz;
      final d = 2.0 * rawMass * dampingRatio * omega;
      final springK = rawMass * omega * omega;
      final h = dt;
      _gamma = h * (d + h * springK);
      _gamma = _gamma > 1e-12 ? 1.0 / _gamma : 0.0;
      _bias = c * h * springK * _gamma;
      final invEff = k + _gamma;
      _effMass = invEff > 1e-12 ? 1.0 / invEff : 0.0;
    } else {
      _gamma = 0.0;
      _bias = 0.0;
      _effMass = rawMass;
    }
    _accumImpulse = 0.0;
  }

  @override
  void solveVelocity(double dt) {
    if (_effMass <= 0.0) {
      return;
    }
    final vRel = _relVelAlongAxis(bodyA, _rA, bodyB, _rB, _u);
    final impulse = -_effMass * (vRel + _bias + _gamma * _accumImpulse);
    _accumImpulse += impulse;
    _applyLinearPairImpulse(
      bodyA,
      _rA,
      bodyB,
      _rB,
      _u.x * impulse,
      _u.y * impulse,
      _u.z * impulse,
      _scratch,
    );
  }

  @override
  void solvePosition() {
    if (frequencyHz > 0.0) {
      return;
    }
    _rotateQuat(bodyA.bodyRotation, localAnchorA, _rA);
    _rotateQuat(bodyB.bodyRotation, localAnchorB, _rB);
    final dx = (bodyB.bodyPosition.x + _rB.x) - (bodyA.bodyPosition.x + _rA.x);
    final dy = (bodyB.bodyPosition.y + _rB.y) - (bodyA.bodyPosition.y + _rA.y);
    final dz = (bodyB.bodyPosition.z + _rB.z) - (bodyA.bodyPosition.z + _rA.z);
    final curLen = math.sqrt(dx * dx + dy * dy + dz * dz);
    if (curLen <= 1e-7) {
      return;
    }
    _u.setValues(dx / curLen, dy / curLen, dz / curLen);
    final err = (curLen - length) * 0.5;
    if (err.abs() <= 1e-5) {
      return;
    }
    final k = _computeLinearAxisK(bodyA, _rA, bodyB, _rB, _u, _scratch);
    if (k <= 1e-12) {
      return;
    }
    final lambda = -err / k;
    _applyPositionPairImpulse(
      bodyA,
      _rA,
      bodyB,
      _rB,
      _u.x * lambda,
      _u.y * lambda,
      _u.z * lambda,
      _scratch,
    );
  }
}

/// 3-DOF point-to-point (spherical / ball-and-socket) joint locking
/// [localAnchorA] on [bodyA] to [localAnchorB] on [bodyB].
class BallSocketJoint3D({
  required super.bodyA,
  required super.bodyB,
  Vector3? localAnchorA,
  Vector3? localAnchorB,
  super.collideConnected,
}) extends Joint3D {
  /// Anchor point in [bodyA]'s local space.
  final Vector3 localAnchorA = localAnchorA?.clone() ?? Vector3.zero();

  /// Anchor point in [bodyB]'s local space.
  final Vector3 localAnchorB = localAnchorB?.clone() ?? Vector3.zero();

  final Vector3 _rA = Vector3.zero();
  final Vector3 _rB = Vector3.zero();
  final Matrix3 _effMass3 = Matrix3.zero();
  final Vector3 _bias = Vector3.zero();
  final Vector3 _rhs = Vector3.zero();
  final Vector3 _imp = Vector3.zero();
  final Vector3 _scratch = Vector3.zero();

  @override
  void prepare(double dt) {
    _rotateQuat(bodyA.bodyRotation, localAnchorA, _rA);
    _rotateQuat(bodyB.bodyRotation, localAnchorB, _rB);
    _buildPointToPointInvK(bodyA, _rA, bodyB, _rB, _effMass3);

    if (dt > 1e-9) {
      const beta = 0.2;
      final scale = beta / dt;
      _bias.setValues(
        ((bodyB.bodyPosition.x + _rB.x) - (bodyA.bodyPosition.x + _rA.x)) *
            scale,
        ((bodyB.bodyPosition.y + _rB.y) - (bodyA.bodyPosition.y + _rA.y)) *
            scale,
        ((bodyB.bodyPosition.z + _rB.z) - (bodyA.bodyPosition.z + _rA.z)) *
            scale,
      );
    } else {
      _bias.setZero();
    }
  }

  @override
  void solveVelocity(double dt) {
    _relVel3(bodyA, _rA, bodyB, _rB, _rhs);
    _rhs.add(_bias);
    _mulMat3Neg(_effMass3, _rhs, _imp);
    _applyLinearPairImpulse(
      bodyA,
      _rA,
      bodyB,
      _rB,
      _imp.x,
      _imp.y,
      _imp.z,
      _scratch,
    );
  }

  @override
  void solvePosition() {
    _rotateQuat(bodyA.bodyRotation, localAnchorA, _rA);
    _rotateQuat(bodyB.bodyRotation, localAnchorB, _rB);
    final ex = (bodyB.bodyPosition.x + _rB.x) - (bodyA.bodyPosition.x + _rA.x);
    final ey = (bodyB.bodyPosition.y + _rB.y) - (bodyA.bodyPosition.y + _rA.y);
    final ez = (bodyB.bodyPosition.z + _rB.z) - (bodyA.bodyPosition.z + _rA.z);
    if (ex * ex + ey * ey + ez * ez <= 1e-9) {
      return;
    }
    _buildPointToPointInvK(bodyA, _rA, bodyB, _rB, _effMass3);
    _rhs.setValues(ex * 0.4, ey * 0.4, ez * 0.4);
    _mulMat3Neg(_effMass3, _rhs, _imp);
    _applyPositionPairImpulse(
      bodyA,
      _rA,
      bodyB,
      _rB,
      _imp.x,
      _imp.y,
      _imp.z,
      _scratch,
    );
  }
}

/// 1-DOF revolute hinge joint locking anchor positions and aligning
/// [localAxisA] with [localAxisB], with optional twist angle limits
/// `[minAngle..maxAngle]` (in radians).
class HingeJoint3D({
  required super.bodyA,
  required super.bodyB,
  Vector3? localAnchorA,
  Vector3? localAnchorB,
  Vector3? localAxisA,
  Vector3? localAxisB,
  var double? minAngle,
  var double? maxAngle,
  super.collideConnected,
}) extends Joint3D {
  this
    : assert(
        minAngle == null || maxAngle == null || minAngle <= maxAngle,
        'minAngle must be <= maxAngle',
      ) {
    _buildOrthonormalBasis(this.localAxisA, _perp1A, _perp2A);
    if (localAxisB != null) {
      this.localAxisB
        ..setFrom(localAxisB)
        ..normalize();
    } else {
      // Express world axis of A in B's initial local frame so initial pose has
      // zero swing error.
      final worldAxis = Vector3.zero();
      _rotateQuat(bodyA.bodyRotation, this.localAxisA, worldAxis);
      _unrotateQuat(bodyB.bodyRotation, worldAxis, this.localAxisB);
      this.localAxisB.normalize();
    }
    // Express A's reference `_perp1A` in B's local frame so `jointAngle == 0`
    // in the initial configuration!
    final worldPerp1 = Vector3.zero();
    final candB = Vector3.zero();
    _rotateQuat(bodyA.bodyRotation, _perp1A, worldPerp1);
    _unrotateQuat(bodyB.bodyRotation, worldPerp1, candB);
    candB.addScaled(this.localAxisB, -candB.dot(this.localAxisB));
    if (candB.length2 > 1e-10) {
      _perp1B
        ..setFrom(candB)
        ..normalize();
    } else {
      final dummy = Vector3.zero();
      _buildOrthonormalBasis(this.localAxisB, _perp1B, dummy);
    }
  }

  /// Anchor point in [bodyA]'s local space.
  final Vector3 localAnchorA = localAnchorA?.clone() ?? Vector3.zero();

  /// Anchor point in [bodyB]'s local space.
  final Vector3 localAnchorB = localAnchorB?.clone() ?? Vector3.zero();

  /// Unit hinge axis in [bodyA]'s local space.
  final Vector3 localAxisA = (localAxisA?.clone() ?? Vector3(0.0, 0.0, 1.0))
    ..normalize();

  /// Unit hinge axis in [bodyB]'s local space.
  final Vector3 localAxisB = Vector3.zero();

  final Vector3 _perp1A = Vector3.zero();
  final Vector3 _perp2A = Vector3.zero();
  final Vector3 _perp1B = Vector3.zero();

  final Vector3 _rA = Vector3.zero();
  final Vector3 _rB = Vector3.zero();
  final Matrix3 _linearMass = Matrix3.zero();
  final Vector3 _linearBias = Vector3.zero();

  final Vector3 _a1 = Vector3.zero();
  final Vector3 _a2 = Vector3.zero();
  final Vector3 _b2 = Vector3.zero();
  final Vector3 _c2 = Vector3.zero();
  final Vector3 _u1 = Vector3.zero();
  final Vector3 _v1 = Vector3.zero();
  final Vector3 _u2 = Vector3.zero();

  double _swingM00 = 0.0;
  double _swingM01 = 0.0;
  double _swingM11 = 0.0;
  double _swingBias0 = 0.0;
  double _swingBias1 = 0.0;

  int _limitState = 0; // -1 = lower, 0 = inactive, +1 = upper, 2 = locked
  double _twistMass = 0.0;
  double _limitBias = 0.0;
  double _limitAccum = 0.0;

  final Vector3 _rhs = Vector3.zero();
  final Vector3 _imp = Vector3.zero();
  final Vector3 _scratch = Vector3.zero();
  final Vector3 _scratch2 = Vector3.zero();

  /// Current signed twist angle (radians) of [bodyB] relative to [bodyA] around
  /// the hinge axis.
  double get jointAngle {
    _rotateQuat(bodyA.bodyRotation, _perp1A, _u1);
    _rotateQuat(bodyA.bodyRotation, _perp2A, _v1);
    _rotateQuat(bodyB.bodyRotation, _perp1B, _u2);
    return math.atan2(_u2.dot(_v1), _u2.dot(_u1));
  }

  @override
  void prepare(double dt) {
    _rotateQuat(bodyA.bodyRotation, localAnchorA, _rA);
    _rotateQuat(bodyB.bodyRotation, localAnchorB, _rB);
    _buildPointToPointInvK(bodyA, _rA, bodyB, _rB, _linearMass);

    final invDt = dt > 1e-9 ? 1.0 / dt : 0.0;
    const betaLin = 0.2;
    _linearBias.setValues(
      ((bodyB.bodyPosition.x + _rB.x) - (bodyA.bodyPosition.x + _rA.x)) *
          betaLin *
          invDt,
      ((bodyB.bodyPosition.y + _rB.y) - (bodyA.bodyPosition.y + _rA.y)) *
          betaLin *
          invDt,
      ((bodyB.bodyPosition.z + _rB.z) - (bodyA.bodyPosition.z + _rA.z)) *
          betaLin *
          invDt,
    );

    // Swing basis perpendicular to `a1`.
    _rotateQuat(bodyA.bodyRotation, localAxisA, _a1);
    _rotateQuat(bodyB.bodyRotation, localAxisB, _a2);
    _buildOrthonormalBasis(_a1, _b2, _c2);

    // 2x2 angular effective mass on `(_b2, _c2)` using `I_A^-1 + I_B^-1`.
    _sumInvInertiaMul(bodyA, bodyB, _b2, _scratch);
    final k00 = _b2.dot(_scratch);
    final k01 = _c2.dot(_scratch);
    _sumInvInertiaMul(bodyA, bodyB, _c2, _scratch);
    final k11 = _c2.dot(_scratch);
    final det = k00 * k11 - k01 * k01;
    if (det.abs() > 1e-14) {
      final invDet = 1.0 / det;
      _swingM00 = k11 * invDet;
      _swingM01 = -k01 * invDet;
      _swingM11 = k00 * invDet;
    } else {
      _swingM00 = 0.0;
      _swingM01 = 0.0;
      _swingM11 = 0.0;
    }

    // Swing angular error `err = a1 x a2`; target `(wB - wA) = -(beta/dt)*err`.
    final errX = _a1.y * _a2.z - _a1.z * _a2.y;
    final errY = _a1.z * _a2.x - _a1.x * _a2.z;
    final errZ = _a1.x * _a2.y - _a1.y * _a2.x;
    const betaAng = 0.25;
    _swingBias0 =
        (errX * _b2.x + errY * _b2.y + errZ * _b2.z) * betaAng * invDt;
    _swingBias1 =
        (errX * _c2.x + errY * _c2.y + errZ * _c2.z) * betaAng * invDt;

    // Optional twist limits around `_a1`.
    _limitState = 0;
    _limitBias = 0.0;
    _limitAccum = 0.0;
    if (minAngle != null || maxAngle != null) {
      _sumInvInertiaMul(bodyA, bodyB, _a1, _scratch);
      final kTwist = _a1.dot(_scratch);
      _twistMass = kTwist > 1e-12 ? 1.0 / kTwist : 0.0;

      final angle = jointAngle;
      final lo = minAngle;
      final hi = maxAngle;
      if (lo != null && hi != null && (hi - lo).abs() < 1e-4) {
        _limitState = 2;
        _limitBias = (angle - lo) * betaAng * invDt;
      } else if (lo != null && angle <= lo) {
        _limitState = -1;
        _limitBias = (angle - lo) * betaAng * invDt;
      } else if (hi != null && angle >= hi) {
        _limitState = 1;
        _limitBias = (angle - hi) * betaAng * invDt;
      }
    }
  }

  @override
  void solveVelocity(double dt) {
    // 1. Point-to-point linear anchor impulse.
    _relVel3(bodyA, _rA, bodyB, _rB, _rhs);
    _rhs.add(_linearBias);
    _mulMat3Neg(_linearMass, _rhs, _imp);
    _applyLinearPairImpulse(
      bodyA,
      _rA,
      bodyB,
      _rB,
      _imp.x,
      _imp.y,
      _imp.z,
      _scratch,
    );

    // 2. 2-DOF swing angular alignment impulse.
    final dwx = bodyB.angularVelocity.x - bodyA.angularVelocity.x;
    final dwy = bodyB.angularVelocity.y - bodyA.angularVelocity.y;
    final dwz = bodyB.angularVelocity.z - bodyA.angularVelocity.z;
    final cDot0 = dwx * _b2.x + dwy * _b2.y + dwz * _b2.z + _swingBias0;
    final cDot1 = dwx * _c2.x + dwy * _c2.y + dwz * _c2.z + _swingBias1;
    final l0 = -(_swingM00 * cDot0 + _swingM01 * cDot1);
    final l1 = -(_swingM01 * cDot0 + _swingM11 * cDot1);
    _applyAngularPairImpulse(
      bodyA,
      bodyB,
      _b2.x * l0 + _c2.x * l1,
      _b2.y * l0 + _c2.y * l1,
      _b2.z * l0 + _c2.z * l1,
      _scratch,
    );

    // 3. Twist limit impulse around `_a1`.
    if (_limitState != 0 && _twistMass > 0.0) {
      final dwTwist =
          (bodyB.angularVelocity.x - bodyA.angularVelocity.x) * _a1.x +
          (bodyB.angularVelocity.y - bodyA.angularVelocity.y) * _a1.y +
          (bodyB.angularVelocity.z - bodyA.angularVelocity.z) * _a1.z;
      var dLambda = -_twistMass * (dwTwist + _limitBias);
      if (_limitState == -1) {
        final prev = _limitAccum;
        _limitAccum = math.max(0.0, prev + dLambda);
        dLambda = _limitAccum - prev;
      } else if (_limitState == 1) {
        final prev = _limitAccum;
        _limitAccum = math.min(0.0, prev + dLambda);
        dLambda = _limitAccum - prev;
      } else {
        _limitAccum += dLambda;
      }
      if (dLambda.abs() > 1e-12) {
        _applyAngularPairImpulse(
          bodyA,
          bodyB,
          _a1.x * dLambda,
          _a1.y * dLambda,
          _a1.z * dLambda,
          _scratch,
        );
      }
    }
  }

  @override
  void solvePosition() {
    // 1. Anchor position drift correction.
    _rotateQuat(bodyA.bodyRotation, localAnchorA, _rA);
    _rotateQuat(bodyB.bodyRotation, localAnchorB, _rB);
    final ex = (bodyB.bodyPosition.x + _rB.x) - (bodyA.bodyPosition.x + _rA.x);
    final ey = (bodyB.bodyPosition.y + _rB.y) - (bodyA.bodyPosition.y + _rA.y);
    final ez = (bodyB.bodyPosition.z + _rB.z) - (bodyA.bodyPosition.z + _rA.z);
    if (ex * ex + ey * ey + ez * ez > 1e-9) {
      _buildPointToPointInvK(bodyA, _rA, bodyB, _rB, _linearMass);
      _rhs.setValues(ex * 0.4, ey * 0.4, ez * 0.4);
      _mulMat3Neg(_linearMass, _rhs, _imp);
      _applyPositionPairImpulse(
        bodyA,
        _rA,
        bodyB,
        _rB,
        _imp.x,
        _imp.y,
        _imp.z,
        _scratch,
      );
    }

    // 2. Swing & twist limit angular drift correction.
    _rotateQuat(bodyA.bodyRotation, localAxisA, _a1);
    _rotateQuat(bodyB.bodyRotation, localAxisB, _a2);
    final errX = _a1.y * _a2.z - _a1.z * _a2.y;
    final errY = _a1.z * _a2.x - _a1.x * _a2.z;
    final errZ = _a1.x * _a2.y - _a1.y * _a2.x;
    if (errX * errX + errY * errY + errZ * errZ > 1e-8) {
      _scratch2.setValues(errX, errY, errZ);
      _sumInvInertiaMul(bodyA, bodyB, _scratch2, _scratch);
      final denom = _scratch2.dot(_scratch);
      if (denom > 1e-12) {
        final scale = -0.4 * _scratch2.length2 / denom;
        _applyAngularPositionPairImpulse(
          bodyA,
          bodyB,
          errX * scale,
          errY * scale,
          errZ * scale,
          _scratch,
        );
      }
    }

    if (minAngle != null || maxAngle != null) {
      _rotateQuat(bodyA.bodyRotation, localAxisA, _a1);
      final angle = jointAngle;
      var angleErr = 0.0;
      if (minAngle != null && angle < minAngle!) {
        angleErr = angle - minAngle!;
      } else if (maxAngle != null && angle > maxAngle!) {
        angleErr = angle - maxAngle!;
      }
      if (angleErr.abs() > 1e-4) {
        _sumInvInertiaMul(bodyA, bodyB, _a1, _scratch);
        final k = _a1.dot(_scratch);
        if (k > 1e-12) {
          final tau = -(angleErr * 0.5) / k;
          _applyAngularPositionPairImpulse(
            bodyA,
            bodyB,
            _a1.x * tau,
            _a1.y * tau,
            _a1.z * tau,
            _scratch,
          );
        }
      }
    }
  }
}

void _rotateQuat(Quaternion q, Vector3 v, Vector3 out) {
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

void _unrotateQuat(Quaternion q, Vector3 v, Vector3 out) {
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

void _buildOrthonormalBasis(Vector3 n, Vector3 t1, Vector3 t2) {
  if (n.x.abs() < 0.9) {
    t1.setValues(0.0, -n.z, n.y);
  } else {
    t1.setValues(-n.z, 0.0, n.x);
  }
  t1.normalize();
  t2.setValues(
    n.y * t1.z - n.z * t1.y,
    n.z * t1.x - n.x * t1.z,
    n.x * t1.y - n.y * t1.x,
  );
}

double _computeLinearAxisK(
  RigidBody3D a,
  Vector3 rA,
  RigidBody3D b,
  Vector3 rB,
  Vector3 u,
  Vector3 scratch,
) {
  var k = a.inverseMass + b.inverseMass;
  if (a.inverseMass > 0.0) {
    final cx = rA.y * u.z - rA.z * u.y;
    final cy = rA.z * u.x - rA.x * u.z;
    final cz = rA.x * u.y - rA.y * u.x;
    a.multiplyWorldInvInertia(cx, cy, cz, scratch);
    k += cx * scratch.x + cy * scratch.y + cz * scratch.z;
  }
  if (b.inverseMass > 0.0) {
    final cx = rB.y * u.z - rB.z * u.y;
    final cy = rB.z * u.x - rB.x * u.z;
    final cz = rB.x * u.y - rB.y * u.x;
    b.multiplyWorldInvInertia(cx, cy, cz, scratch);
    k += cx * scratch.x + cy * scratch.y + cz * scratch.z;
  }
  return k;
}

void _buildPointToPointInvK(
  RigidBody3D a,
  Vector3 rA,
  RigidBody3D b,
  Vector3 rB,
  Matrix3 invKOut,
) {
  final invM = a.inverseMass + b.inverseMass;
  var k00 = invM;
  var k01 = 0.0;
  var k02 = 0.0;
  var k11 = invM;
  var k12 = 0.0;
  var k22 = invM;

  void addSkewInertia(RigidBody3D body, Vector3 r) {
    if (body.inverseMass <= 0.0) {
      return;
    }
    // `-[r]_x * I * [r]_x` where `I = body.worldInvInertia` (symmetric).
    final i = body.worldInvInertia.storage;
    final i00 = i[0];
    final i01 = i[1];
    final i02 = i[2];
    final i11 = i[4];
    final i12 = i[5];
    final i22 = i[8];
    final rx = r.x;
    final ry = r.y;
    final rz = r.z;

    // Columns of `I * [r]_x`: `[r]_x * e_0 = (0, rz, -ry)`, etc.
    // Specifically `(v^T (-[r]_x I [r]_x) v) = (r x v)^T I (r x v)`:
    // For basis vectors e_x, e_y, e_z:
    // c0 = r x e_x = (0, rz, -ry)
    // c1 = r x e_y = (-rz, 0, rx)
    // c2 = r x e_z = (ry, -rx, 0)
    final ic0y = i01 * 0.0 + i11 * rz - i12 * ry;
    final ic0z = i02 * 0.0 + i12 * rz - i22 * ry;

    final ic1x = -i00 * rz + i02 * rx;
    final ic1z = -i02 * rz + i22 * rx;

    final ic2x = i00 * ry - i01 * rx;
    final ic2y = i01 * ry - i11 * rx;

    k00 += rz * ic0y - ry * ic0z;
    k01 += -rz * (i01 * rz - i02 * ry) + rx * ic0z;
    k02 += ry * (i01 * rz - i02 * ry) - rx * ic0y;
    k11 += -rz * ic1x + rx * ic1z;
    k12 += ry * ic1x - rx * (-i01 * rz + i12 * rx);
    k22 += ry * ic2x - rx * ic2y;
  }

  addSkewInertia(a, rA);
  addSkewInertia(b, rB);

  final c00 = k11 * k22 - k12 * k12;
  final c01 = -(k01 * k22 - k12 * k02);
  final c02 = k01 * k12 - k11 * k02;
  final c11 = k00 * k22 - k02 * k02;
  final c12 = -(k00 * k12 - k01 * k02);
  final c22 = k00 * k11 - k01 * k01;

  final det = k00 * c00 + k01 * c01 + k02 * c02;
  if (det.abs() <= 1e-14) {
    invKOut.setZero();
    return;
  }
  final invDet = 1.0 / det;
  final s = invKOut.storage;
  s[0] = c00 * invDet;
  s[1] = c01 * invDet;
  s[2] = c02 * invDet;
  s[3] = c01 * invDet;
  s[4] = c11 * invDet;
  s[5] = c12 * invDet;
  s[6] = c02 * invDet;
  s[7] = c12 * invDet;
  s[8] = c22 * invDet;
}

void _mulMat3Neg(Matrix3 m, Vector3 v, Vector3 out) {
  final s = m.storage;
  out.setValues(
    -(s[0] * v.x + s[3] * v.y + s[6] * v.z),
    -(s[1] * v.x + s[4] * v.y + s[7] * v.z),
    -(s[2] * v.x + s[5] * v.y + s[8] * v.z),
  );
}

void _sumInvInertiaMul(
  RigidBody3D a,
  RigidBody3D b,
  Vector3 v,
  Vector3 out,
) {
  final sA = a.worldInvInertia.storage;
  final sB = b.worldInvInertia.storage;
  out.setValues(
    (sA[0] + sB[0]) * v.x + (sA[3] + sB[3]) * v.y + (sA[6] + sB[6]) * v.z,
    (sA[1] + sB[1]) * v.x + (sA[4] + sB[4]) * v.y + (sA[7] + sB[7]) * v.z,
    (sA[2] + sB[2]) * v.x + (sA[5] + sB[5]) * v.y + (sA[8] + sB[8]) * v.z,
  );
}

double _relVelAlongAxis(
  RigidBody3D a,
  Vector3 rA,
  RigidBody3D b,
  Vector3 rB,
  Vector3 u,
) {
  final vAx =
      a.linearVelocity.x +
      (a.angularVelocity.y * rA.z - a.angularVelocity.z * rA.y);
  final vAy =
      a.linearVelocity.y +
      (a.angularVelocity.z * rA.x - a.angularVelocity.x * rA.z);
  final vAz =
      a.linearVelocity.z +
      (a.angularVelocity.x * rA.y - a.angularVelocity.y * rA.x);

  final vBx =
      b.linearVelocity.x +
      (b.angularVelocity.y * rB.z - b.angularVelocity.z * rB.y);
  final vBy =
      b.linearVelocity.y +
      (b.angularVelocity.z * rB.x - b.angularVelocity.x * rB.z);
  final vBz =
      b.linearVelocity.z +
      (b.angularVelocity.x * rB.y - b.angularVelocity.y * rB.x);

  return (vBx - vAx) * u.x + (vBy - vAy) * u.y + (vBz - vAz) * u.z;
}

void _relVel3(
  RigidBody3D a,
  Vector3 rA,
  RigidBody3D b,
  Vector3 rB,
  Vector3 out,
) {
  final vAx =
      a.linearVelocity.x +
      (a.angularVelocity.y * rA.z - a.angularVelocity.z * rA.y);
  final vAy =
      a.linearVelocity.y +
      (a.angularVelocity.z * rA.x - a.angularVelocity.x * rA.z);
  final vAz =
      a.linearVelocity.z +
      (a.angularVelocity.x * rA.y - a.angularVelocity.y * rA.x);

  final vBx =
      b.linearVelocity.x +
      (b.angularVelocity.y * rB.z - b.angularVelocity.z * rB.y);
  final vBy =
      b.linearVelocity.y +
      (b.angularVelocity.z * rB.x - b.angularVelocity.x * rB.z);
  final vBz =
      b.linearVelocity.z +
      (b.angularVelocity.x * rB.y - b.angularVelocity.y * rB.x);

  out.setValues(vBx - vAx, vBy - vAy, vBz - vAz);
}

void _applyLinearPairImpulse(
  RigidBody3D a,
  Vector3 rA,
  RigidBody3D b,
  Vector3 rB,
  double px,
  double py,
  double pz,
  Vector3 scratch,
) {
  if (a.inverseMass > 0.0) {
    a.linearVelocity.setValues(
      a.linearVelocity.x - px * a.inverseMass,
      a.linearVelocity.y - py * a.inverseMass,
      a.linearVelocity.z - pz * a.inverseMass,
    );
    final tx = rA.y * pz - rA.z * py;
    final ty = rA.z * px - rA.x * pz;
    final tz = rA.x * py - rA.y * px;
    a.multiplyWorldInvInertia(tx, ty, tz, scratch);
    a.angularVelocity.sub(scratch);
  }
  if (b.inverseMass > 0.0) {
    b.linearVelocity.setValues(
      b.linearVelocity.x + px * b.inverseMass,
      b.linearVelocity.y + py * b.inverseMass,
      b.linearVelocity.z + pz * b.inverseMass,
    );
    final tx = rB.y * pz - rB.z * py;
    final ty = rB.z * px - rB.x * pz;
    final tz = rB.x * py - rB.y * px;
    b.multiplyWorldInvInertia(tx, ty, tz, scratch);
    b.angularVelocity.add(scratch);
  }
}

void _applyAngularPairImpulse(
  RigidBody3D a,
  RigidBody3D b,
  double tx,
  double ty,
  double tz,
  Vector3 scratch,
) {
  if (a.inverseMass > 0.0) {
    a.multiplyWorldInvInertia(tx, ty, tz, scratch);
    a.angularVelocity.sub(scratch);
  }
  if (b.inverseMass > 0.0) {
    b.multiplyWorldInvInertia(tx, ty, tz, scratch);
    b.angularVelocity.add(scratch);
  }
}

void _applyPositionPairImpulse(
  RigidBody3D a,
  Vector3 rA,
  RigidBody3D b,
  Vector3 rB,
  double px,
  double py,
  double pz,
  Vector3 scratch,
) {
  if (a.inverseMass > 0.0) {
    final posA = a.bodyPosition;
    posA.setValues(
      posA.x - px * a.inverseMass,
      posA.y - py * a.inverseMass,
      posA.z - pz * a.inverseMass,
    );
    final tx = rA.y * pz - rA.z * py;
    final ty = rA.z * px - rA.x * pz;
    final tz = rA.x * py - rA.y * px;
    a.multiplyWorldInvInertia(-tx, -ty, -tz, scratch);
    _integratePseudoRotation(a, scratch);
  }
  if (b.inverseMass > 0.0) {
    final posB = b.bodyPosition;
    posB.setValues(
      posB.x + px * b.inverseMass,
      posB.y + py * b.inverseMass,
      posB.z + pz * b.inverseMass,
    );
    final tx = rB.y * pz - rB.z * py;
    final ty = rB.z * px - rB.x * pz;
    final tz = rB.x * py - rB.y * px;
    b.multiplyWorldInvInertia(tx, ty, tz, scratch);
    _integratePseudoRotation(b, scratch);
  }
}

void _applyAngularPositionPairImpulse(
  RigidBody3D a,
  RigidBody3D b,
  double tx,
  double ty,
  double tz,
  Vector3 scratch,
) {
  if (a.inverseMass > 0.0) {
    a.multiplyWorldInvInertia(-tx, -ty, -tz, scratch);
    _integratePseudoRotation(a, scratch);
  }
  if (b.inverseMass > 0.0) {
    b.multiplyWorldInvInertia(tx, ty, tz, scratch);
    _integratePseudoRotation(b, scratch);
  }
}

void _integratePseudoRotation(RigidBody3D body, Vector3 dTheta) {
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

  var nx = dqw * qx + dqx * qw + dqy * qz - dqz * qy;
  var ny = dqw * qy - dqx * qz + dqy * qw + dqz * qx;
  var nz = dqw * qz + dqx * qy - dqy * qx + dqz * qw;
  var nw = dqw * qw - dqx * qx - dqy * qy - dqz * qz;
  final invLen = 1.0 / math.sqrt(nx * nx + ny * ny + nz * nz + nw * nw);
  nx *= invLen;
  ny *= invLen;
  nz *= invLen;
  nw *= invLen;
  q.setValues(nx, ny, nz, nw);
  body.updateWorldInertia();
}
