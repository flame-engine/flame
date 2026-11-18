import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame_3d/camera.dart';

/// Trauma-based 6-DOF (3D position + pitch/yaw/roll angular) camera shake
/// component for a [CameraComponent3D].
///
/// Shake amplitude scales quadratically (`trauma ^ 2`) and applies a
/// deterministic, drift-free multi-frequency smooth noise offset around the
/// camera's underlying base eye, target, and up vectors.
class CameraShake3D({
  CameraComponent3D? camera,
  var double traumaDecay = 1.2,
  var double maxPositionOffset = 0.35,
  var double maxAngleRad = 0.06,
  var double frequency = 18.0,
  final int seed = 1337,
  super.priority,
  super.key,
}) extends Component {
  final CameraComponent3D? _explicitCamera = camera;
  CameraComponent3D? _mountedCamera;

  double _trauma = 0.0;
  double _elapsed = 0.0;

  bool _hasAppliedShake = false;
  final Vector3 _appliedPosDelta = Vector3.zero();
  final Vector3 _appliedTargetDelta = Vector3.zero();
  final Vector3 _lastShakenPos = Vector3.zero();
  final Vector3 _lastShakenTarget = Vector3.zero();
  final Vector3 _savedBaseUp = Vector3(0, 1, 0);
  final Vector3 _lastShakenUp = Vector3(0, 1, 0);

  final Vector3 _forward = Vector3.zero();
  final Vector3 _right = Vector3.zero();
  final Vector3 _orthoUp = Vector3.zero();
  final Vector3 _rotatedForward = Vector3.zero();
  final Vector3 _rotatedUp = Vector3.zero();
  final Quaternion _rotQuat = Quaternion.identity();
  final Quaternion _pitchQuat = Quaternion.identity();
  final Quaternion _yawQuat = Quaternion.identity();
  final Quaternion _rollQuat = Quaternion.identity();

  /// Current trauma level in `[0..1]`.
  double get trauma => _trauma;
  set trauma(double value) => _trauma = value.clamp(0.0, 1.0);

  /// Quadratic shake intensity (`trauma * trauma`) in `[0..1]`.
  double get shakeIntensity => _trauma * _trauma;

  /// Resolved [CameraComponent3D] driven by this shake component.
  CameraComponent3D get camera {
    final resolved = _resolveCamera();
    if (resolved == null) {
      throw StateError(
        'CameraShake3D requires a CameraComponent3D passed to its constructor '
        'or present as an ancestor.',
      );
    }
    return resolved;
  }

  CameraComponent3D? _resolveCamera() {
    if (_explicitCamera != null) {
      return _explicitCamera;
    }
    if (_mountedCamera != null) {
      return _mountedCamera;
    }
    for (final ancestor in ancestors()) {
      if (ancestor is CameraComponent3D) {
        return _mountedCamera = ancestor;
      }
    }
    return null;
  }

  /// Adds [amount] to [trauma], clamped to `[0..1]`.
  void addTrauma(double amount) {
    _trauma = (_trauma + amount).clamp(0.0, 1.0);
  }

  /// Clears all active trauma and immediately restores the unshaken camera
  /// pose.
  void reset() {
    final cam = _resolveCamera();
    if (cam != null) {
      _removePreviousShakeIfUnmodified(cam);
    }
    _trauma = 0.0;
    _elapsed = 0.0;
  }

  @override
  void onMount() {
    super.onMount();
    _mountedCamera = null;
  }

  @override
  void onRemove() {
    final cam = _resolveCamera();
    if (cam != null) {
      _removePreviousShakeIfUnmodified(cam);
    }
    _mountedCamera = null;
    super.onRemove();
  }

  @override
  void update(double dt) {
    super.update(dt);
    final cam = _resolveCamera();
    if (cam == null) {
      return;
    }

    _removePreviousShakeIfUnmodified(cam);

    if (dt > 0) {
      _elapsed += dt;
      if (traumaDecay > 0) {
        _trauma = math.max(0.0, _trauma - traumaDecay * dt);
      }
    }

    final intensity = shakeIntensity;
    if (intensity <= 1e-9) {
      return;
    }

    _forward
      ..setFrom(cam.target)
      ..sub(cam.position);
    final lookDist = _forward.length;
    if (lookDist <= 1e-9) {
      return;
    }
    _forward.scale(1.0 / lookDist);

    _savedBaseUp.setFrom(cam.up);
    _forward.crossInto(_savedBaseUp, _right);
    if (_right.length2 <= 1e-8) {
      final fallback = _forward.y.abs() < 0.9
          ? Vector3(0, 1, 0)
          : Vector3(1, 0, 0);
      _forward.crossInto(fallback, _right);
    }
    _right.normalize();
    _right.crossInto(_forward, _orthoUp);
    _orthoUp.normalize();

    final t = _elapsed * frequency;
    final nx = _smoothNoise(t, 0);
    final ny = _smoothNoise(t, 1);
    final nz = _smoothNoise(t, 2);
    final nPitch = _smoothNoise(t, 3);
    final nYaw = _smoothNoise(t, 4);
    final nRoll = _smoothNoise(t, 5);

    final posAmp = maxPositionOffset * intensity;
    final dx = (_right.x * nx + _orthoUp.x * ny + _forward.x * nz) * posAmp;
    final dy = (_right.y * nx + _orthoUp.y * ny + _forward.y * nz) * posAmp;
    final dz = (_right.z * nx + _orthoUp.z * ny + _forward.z * nz) * posAmp;

    final angAmp = maxAngleRad * intensity;
    _yawQuat.setAxisAngle(_orthoUp, nYaw * angAmp);
    _pitchQuat.setAxisAngle(_right, nPitch * angAmp);
    _rollQuat.setAxisAngle(_forward, nRoll * angAmp);

    _multiplyQuat(_yawQuat, _pitchQuat, _rotQuat);
    _multiplyQuat(_rollQuat, _rotQuat, _rotQuat);

    _rotatedForward
      ..setFrom(_forward)
      ..applyQuaternion(_rotQuat)
      ..scale(lookDist);
    _rotatedUp
      ..setFrom(_savedBaseUp)
      ..applyQuaternion(_rotQuat)
      ..normalize();

    final baseEyeX = cam.position.x;
    final baseEyeY = cam.position.y;
    final baseEyeZ = cam.position.z;
    final baseTargetX = cam.target.x;
    final baseTargetY = cam.target.y;
    final baseTargetZ = cam.target.z;

    final nextEyeX = baseEyeX + dx;
    final nextEyeY = baseEyeY + dy;
    final nextEyeZ = baseEyeZ + dz;
    final nextTargetX = nextEyeX + _rotatedForward.x;
    final nextTargetY = nextEyeY + _rotatedForward.y;
    final nextTargetZ = nextEyeZ + _rotatedForward.z;

    cam.position.setValues(nextEyeX, nextEyeY, nextEyeZ);
    cam.target.setValues(nextTargetX, nextTargetY, nextTargetZ);
    cam.up = _rotatedUp;

    _appliedPosDelta.setValues(dx, dy, dz);
    _appliedTargetDelta.setValues(
      nextTargetX - baseTargetX,
      nextTargetY - baseTargetY,
      nextTargetZ - baseTargetZ,
    );
    _lastShakenPos.setFrom(cam.position);
    _lastShakenTarget.setFrom(cam.target);
    _lastShakenUp.setFrom(cam.up);
    _hasAppliedShake = true;
  }

  void _removePreviousShakeIfUnmodified(CameraComponent3D cam) {
    if (!_hasAppliedShake) {
      return;
    }
    if (_sameVec3(cam.position, _lastShakenPos)) {
      cam.position.sub(_appliedPosDelta);
    }
    if (_sameVec3(cam.target, _lastShakenTarget)) {
      cam.target.sub(_appliedTargetDelta);
    }
    if (_sameVec3(cam.up, _lastShakenUp)) {
      cam.up = _savedBaseUp;
    }
    _appliedPosDelta.setZero();
    _appliedTargetDelta.setZero();
    _hasAppliedShake = false;
  }

  double _smoothNoise(double t, int channel) {
    final hash = (seed * 1103515245 + (channel + 1) * 12345) & 0x7fffffff;
    final p1 = (hash % 6283) * 0.001 + 0.37;
    final p2 = ((hash >> 7) % 6283) * 0.001 + 1.13;
    final p3 = ((hash >> 14) % 6283) * 0.001 + 2.41;
    final f = 1.0 + channel * 0.07;
    return 0.55 * math.sin(t * f + p1) +
        0.3 * math.sin(t * f * 2.31 + p2) +
        0.15 * math.sin(t * f * 4.17 + p3);
  }

  static bool _sameVec3(Vector3 a, Vector3 b) =>
      (a.x - b.x).abs() <= 1e-6 &&
      (a.y - b.y).abs() <= 1e-6 &&
      (a.z - b.z).abs() <= 1e-6;

  static void _multiplyQuat(Quaternion a, Quaternion b, Quaternion out) {
    final ax = a.x;
    final ay = a.y;
    final az = a.z;
    final aw = a.w;
    final bx = b.x;
    final by = b.y;
    final bz = b.z;
    final bw = b.w;
    out.setValues(
      aw * bx + ax * bw + ay * bz - az * by,
      aw * by - ax * bz + ay * bw + az * bx,
      aw * bz + ax * by - ay * bx + az * bw,
      aw * bw - ax * bx - ay * by - az * bz,
    );
  }
}
