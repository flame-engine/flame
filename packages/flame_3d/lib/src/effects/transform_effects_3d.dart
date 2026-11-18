import 'dart:math' as math;

import 'package:flame/effects.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d/src/effects/effect_3d.dart';

/// Translates a [Component3D] smoothly to `destination`.
class MoveToEffect3D(
  Vector3 destination,
  super.controller, {
  super.onComplete,
  super.key,
}) extends Effect3D<Component3D> {
  final Vector3 _destination = destination.clone();
  final Vector3 _delta = Vector3.zero();
  final Vector3 _lastApplied = Vector3.zero();

  @override
  void onStart() {
    super.onStart();
    _delta
      ..setFrom(_destination)
      ..sub(target.position);
    _lastApplied.setZero();
  }

  @override
  void apply(double progress) {
    final dx = _delta.x * progress;
    final dy = _delta.y * progress;
    final dz = _delta.z * progress;
    target.position.setValues(
      target.position.x + (dx - _lastApplied.x),
      target.position.y + (dy - _lastApplied.y),
      target.position.z + (dz - _lastApplied.z),
    );
    _lastApplied.setValues(dx, dy, dz);
  }

  @override
  void reset() {
    super.reset();
    _lastApplied.setZero();
  }
}

/// Translates a [Component3D] by `offset` relative to its starting position.
class MoveByEffect3D(
  Vector3 offset,
  super.controller, {
  super.onComplete,
  super.key,
}) extends Effect3D<Component3D> {
  final Vector3 _offset = offset.clone();
  final Vector3 _lastApplied = Vector3.zero();

  @override
  void onStart() {
    super.onStart();
    _lastApplied.setZero();
  }

  @override
  void apply(double progress) {
    final dx = _offset.x * progress;
    final dy = _offset.y * progress;
    final dz = _offset.z * progress;
    target.position.setValues(
      target.position.x + (dx - _lastApplied.x),
      target.position.y + (dy - _lastApplied.y),
      target.position.z + (dz - _lastApplied.z),
    );
    _lastApplied.setValues(dx, dy, dz);
  }

  @override
  void reset() {
    super.reset();
    _lastApplied.setZero();
  }
}

/// Moves a [Component3D] to `destination` along a parabolic jump arc of peak
/// height [arcHeight] (`4 * p * (1 - p) * arcHeight`) along `upAxis`.
class ArcMoveEffect3D(
  Vector3 destination,
  super.controller, {
  final double arcHeight = 1.5,
  Vector3? upAxis,
  super.onComplete,
  super.key,
}) extends Effect3D<Component3D> {
  final Vector3 _destination = destination.clone();
  final Vector3 _upAxis = _normalizedOrDefault(upAxis, Vector3(0, 1, 0));
  final Vector3 _chord = Vector3.zero();
  final Vector3 _lastApplied = Vector3.zero();

  @override
  void onStart() {
    super.onStart();
    _chord
      ..setFrom(_destination)
      ..sub(target.position);
    _lastApplied.setZero();
  }

  @override
  void apply(double progress) {
    final p = progress.clamp(0.0, 1.0);
    final lift = 4.0 * p * (1.0 - p) * arcHeight;
    final dx = _chord.x * progress + _upAxis.x * lift;
    final dy = _chord.y * progress + _upAxis.y * lift;
    final dz = _chord.z * progress + _upAxis.z * lift;
    target.position.setValues(
      target.position.x + (dx - _lastApplied.x),
      target.position.y + (dy - _lastApplied.y),
      target.position.z + (dz - _lastApplied.z),
    );
    _lastApplied.setValues(dx, dy, dz);
  }

  @override
  void reset() {
    super.reset();
    _lastApplied.setZero();
  }
}

/// Moves a [Component3D] smoothly along a [CatmullRomSpline3D], optionally
/// orienting its forward (`-Z`) axis to the curve tangent.
class SplinePathEffect3D(
  final CatmullRomSpline3D spline,
  super.controller, {
  final bool orientToTangent = false,
  Vector3? upAxis,
  super.onComplete,
  super.key,
}) extends Effect3D<Component3D> {
  final Vector3 _upAxis = _normalizedOrDefault(upAxis, Vector3(0, 1, 0));
  final Vector3 _point = Vector3.zero();
  final Vector3 _tangent = Vector3.zero();
  final Vector3 _right = Vector3.zero();
  final Vector3 _orthoUp = Vector3.zero();
  final Vector3 _back = Vector3.zero();
  final Matrix3 _basis = Matrix3.identity();

  @override
  void apply(double progress) {
    final t = progress.clamp(0.0, 1.0);
    spline.samplePoint(t, out: _point);
    target.position.setFrom(_point);

    if (orientToTangent) {
      spline.sampleTangent(t, out: _tangent);
      _back
        ..setFrom(_tangent)
        ..negate();
      if (_back.length2 > 1e-12) {
        _back.normalize();
        _upAxis.crossInto(_back, _right);
        if (_right.length2 <= 1e-8) {
          final fallback = _upAxis.x.abs() < 0.9
              ? Vector3(1, 0, 0)
              : Vector3(0, 0, 1);
          fallback.crossInto(_back, _right);
        }
        _right.normalize();
        _back.crossInto(_right, _orthoUp);
        _orthoUp.normalize();
        _basis.setColumns(_right, _orthoUp, _back);
        target.rotation.setFromRotation(_basis);
      }
    }
  }
}

/// Rotates a [Component3D] to `targetRotation` using shortest-hemisphere
/// spherical linear interpolation (Slerp).
class RotateToEffect3D(
  Quaternion targetRotation,
  super.controller, {
  super.onComplete,
  super.key,
}) extends Effect3D<Component3D> {
  final Quaternion _targetRotation = targetRotation.normalized();
  final Quaternion _startRotation = Quaternion.identity();

  @override
  void onStart() {
    super.onStart();
    _startRotation
      ..setFrom(target.rotation)
      ..normalize();
  }

  @override
  void apply(double progress) {
    slerpShortestInto(_startRotation, _targetRotation, progress, target);
  }
}

/// Spins (and optionally orbits around `pivot`) a [Component3D] by [radians]
/// around `axis`.
class RotateAroundEffect3D({
  required Vector3 axis,
  required final double radians,
  required EffectController controller,
  Vector3? pivot,
  final bool alignRotation = true,
  super.onComplete,
  super.key,
}) extends Effect3D<Component3D> {
  this : super(controller);

  final Vector3 _unitAxis = _normalizedOrDefault(axis, Vector3(0, 1, 0));
  final Vector3? _pivot = pivot?.clone();
  final Quaternion _startRotation = Quaternion.identity();
  final Vector3 _startOffset = Vector3.zero();
  final Vector3 _rotatedOffset = Vector3.zero();
  final Quaternion _stepQuat = Quaternion.identity();

  @override
  void onStart() {
    super.onStart();
    _startRotation.setFrom(target.rotation);
    if (_pivot case final p?) {
      _startOffset
        ..setFrom(target.position)
        ..sub(p);
    }
  }

  @override
  void apply(double progress) {
    _stepQuat.setAxisAngle(_unitAxis, radians * progress);

    if (_pivot case final p?) {
      _rotatedOffset
        ..setFrom(_startOffset)
        ..applyQuaternion(_stepQuat);
      target.position.setValues(
        p.x + _rotatedOffset.x,
        p.y + _rotatedOffset.y,
        p.z + _rotatedOffset.z,
      );
    }

    if (_pivot == null || alignRotation) {
      final ax = _stepQuat.x;
      final ay = _stepQuat.y;
      final az = _stepQuat.z;
      final aw = _stepQuat.w;
      final bx = _startRotation.x;
      final by = _startRotation.y;
      final bz = _startRotation.z;
      final bw = _startRotation.w;
      var rx = aw * bx + ax * bw + ay * bz - az * by;
      var ry = aw * by - ax * bz + ay * bw + az * bx;
      var rz = aw * bz + ax * by - ay * bx + az * bw;
      var rw = aw * bw - ax * bx - ay * by - az * bz;
      final len = math.sqrt(rx * rx + ry * ry + rz * rz + rw * rw);
      if (len > 1e-12) {
        final inv = 1.0 / len;
        rx *= inv;
        ry *= inv;
        rz *= inv;
        rw *= inv;
      }
      target.rotation.setValues(rx, ry, rz, rw);
    }
  }
}

/// Scales a [Component3D] smoothly to `targetScale`.
class ScaleToEffect3D(
  Vector3 targetScale,
  super.controller, {
  super.onComplete,
  super.key,
}) extends Effect3D<Component3D> {
  final Vector3 _targetScale = targetScale.clone();
  final Vector3 _delta = Vector3.zero();
  final Vector3 _lastApplied = Vector3.zero();

  @override
  void onStart() {
    super.onStart();
    _delta
      ..setFrom(_targetScale)
      ..sub(target.scale);
    _lastApplied.setZero();
  }

  @override
  void apply(double progress) {
    final dx = _delta.x * progress;
    final dy = _delta.y * progress;
    final dz = _delta.z * progress;
    target.scale.setValues(
      target.scale.x + (dx - _lastApplied.x),
      target.scale.y + (dy - _lastApplied.y),
      target.scale.z + (dz - _lastApplied.z),
    );
    _lastApplied.setValues(dx, dy, dz);
  }

  @override
  void reset() {
    super.reset();
    _lastApplied.setZero();
  }
}

/// Applies a volume-preserving squash-and-stretch impulse (`sUp * sSide^2 = 1`)
/// along `upAxis` (`sUp = 1 + intensity * sin(pi * progress)`,
/// `sSide = 1 / sqrt(sUp)`).
class SquashStretchEffect3D({
  required EffectController controller,
  final double intensity = 0.28,
  Vector3? upAxis,
  super.onComplete,
  super.key,
}) extends Effect3D<Component3D> {
  this : super(controller);

  final Vector3 _upAxis = _normalizedOrDefault(upAxis, Vector3(0, 1, 0));
  final Vector3 _baseScale = Vector3.all(1);

  @override
  void onStart() {
    super.onStart();
    _baseScale.setFrom(target.scale);
  }

  @override
  void apply(double progress) {
    if (progress.abs() < 1e-9 || (progress - 1.0).abs() < 1e-9) {
      target.scale.setFrom(_baseScale);
      return;
    }
    final sUp = math.max(0.05, 1.0 + intensity * math.sin(math.pi * progress));
    final sSide = 1.0 / math.sqrt(sUp);

    final wx = _upAxis.x * _upAxis.x;
    final wy = _upAxis.y * _upAxis.y;
    final wz = _upAxis.z * _upAxis.z;
    final fx = math.pow(sUp, wx) * math.pow(sSide, 1.0 - wx);
    final fy = math.pow(sUp, wy) * math.pow(sSide, 1.0 - wy);
    final fz = math.pow(sUp, wz) * math.pow(sSide, 1.0 - wz);

    target.scale.setValues(
      _baseScale.x * fx,
      _baseScale.y * fy,
      _baseScale.z * fz,
    );
  }
}

Vector3 _normalizedOrDefault(Vector3? candidate, Vector3 fallback) {
  if (candidate != null && candidate.length2 > 1e-12) {
    return candidate.normalized();
  }
  return fallback.normalized();
}

/// Writes shortest-hemisphere Slerp between [q0] and [q1] at [t] directly into
/// [component]'s `rotation` with zero heap allocations.
void slerpShortestInto(
  Quaternion q0,
  Quaternion q1,
  double t,
  Component3D component,
) {
  var x1 = q1.x;
  var y1 = q1.y;
  var z1 = q1.z;
  var w1 = q1.w;
  var dot = q0.x * x1 + q0.y * y1 + q0.z * z1 + q0.w * w1;
  if (dot < 0.0) {
    dot = -dot;
    x1 = -x1;
    y1 = -y1;
    z1 = -z1;
    w1 = -w1;
  }
  dot = dot.clamp(0.0, 1.0);

  final double s0;
  final double s1;
  if (1.0 - dot < 1e-6) {
    s0 = 1.0 - t;
    s1 = t;
  } else {
    final omega = math.acos(dot);
    final invSin = 1.0 / math.sin(omega);
    s0 = math.sin((1.0 - t) * omega) * invSin;
    s1 = math.sin(t * omega) * invSin;
  }

  var rx = q0.x * s0 + x1 * s1;
  var ry = q0.y * s0 + y1 * s1;
  var rz = q0.z * s0 + z1 * s1;
  var rw = q0.w * s0 + w1 * s1;
  final len = math.sqrt(rx * rx + ry * ry + rz * rz + rw * rw);
  if (len > 1e-12) {
    final inv = 1.0 / len;
    rx *= inv;
    ry *= inv;
    rz *= inv;
    rw *= inv;
  }
  component.rotation.setValues(rx, ry, rz, rw);
}
