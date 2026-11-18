import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame_3d/camera.dart';

/// Production 3D orbit, zoom, screen-space pan, and `fitAabb` framing
/// controller for a [CameraComponent3D].
///
/// Attachable either directly as a child of a [CameraComponent3D] or to a
/// [World3D] / game tree with [camera] supplied.
class OrbitCameraController3D({
  CameraComponent3D? camera,
  Vector3? target,
  Vector3? upAxis,
  var double yaw = 0.0,
  double pitch = 0.35,
  var double minPitch = -1.55,
  var double maxPitch = 1.55,
  double distance = 8.0,
  var double minDistance = 0.2,
  var double maxDistance = 1000.0,
  var double damping = 12.0,
  super.priority,
  super.key,
}) extends Component {
  this
    : assert(minPitch <= maxPitch, 'minPitch must be <= maxPitch'),
      assert(
        minDistance > 0 && minDistance <= maxDistance,
        '0 < minDistance <= maxDistance is required',
      ) {
    _pitch = pitch.clamp(minPitch, maxPitch);
    _distance = distance.clamp(minDistance, maxDistance);
    _currentYaw = yaw;
    _currentPitch = _pitch;
    _currentDistance = _distance;
    _currentTarget.setFrom(this.target);
    if (_explicitCamera != null) {
      _applyToCamera(_explicitCamera);
    }
  }

  final CameraComponent3D? _explicitCamera = camera;
  CameraComponent3D? _mountedCamera;

  /// World-space pivot point around which the camera orbits.
  final Vector3 target = target?.clone() ?? Vector3.zero();

  /// World-space up axis (`Vector3(0, 1, 0)` for Y-up, `Vector3(0, 0, 1)` for
  /// Z-up).
  Vector3 get upAxis => _upAxis;
  set upAxis(Vector3 value) {
    if (value.length2 > 1e-12) {
      _upAxis
        ..setFrom(value)
        ..normalize();
    }
  }

  final Vector3 _upAxis = (upAxis?.clone() ?? Vector3(0, 1, 0))..normalize();

  late double _pitch;
  late double _distance;

  /// Desired elevation angle in radians, clamped to `[minPitch..maxPitch]`.
  double get pitch => _pitch;
  set pitch(double value) => _pitch = value.clamp(minPitch, maxPitch);

  /// Desired orbit radius in world units, clamped to
  /// `[minDistance..maxDistance]`.
  double get distance => _distance;
  set distance(double value) =>
      _distance = value.clamp(minDistance, maxDistance);

  /// Alias for exponential [damping] rate (`1/s`; `0` disables smoothing).
  double get smoothing => damping;
  set smoothing(double value) => damping = value;

  double _currentYaw = 0.0;
  double _currentPitch = 0.0;
  double _currentDistance = 8.0;
  final Vector3 _currentTarget = Vector3.zero();

  final Vector3 _axisX = Vector3.zero();
  final Vector3 _axisZ = Vector3.zero();
  final Vector3 _right = Vector3.zero();
  final Vector3 _screenUp = Vector3.zero();

  /// Resolved [CameraComponent3D] driven by this controller.
  CameraComponent3D get camera {
    final resolved = _resolveCamera();
    if (resolved == null) {
      throw StateError(
        'OrbitCameraController3D requires a CameraComponent3D passed to its '
        'constructor or present as an ancestor.',
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

  @override
  void onMount() {
    super.onMount();
    _mountedCamera = null;
    final cam = _resolveCamera();
    if (cam != null) {
      _applyToCamera(cam);
    }
  }

  @override
  void onRemove() {
    _mountedCamera = null;
    super.onRemove();
  }

  /// Rotates the desired orbit angles by [dYaw] and [dPitch] radians.
  void orbitBy(double dYaw, double dPitch) {
    yaw += dYaw;
    pitch = _pitch + dPitch;
  }

  /// Zooms by [factor] (`factor > 1` zooms in by reducing [distance];
  /// `0 < factor < 1` zooms out), clamped to `[minDistance..maxDistance]`.
  void zoomByFactor(double factor) {
    if (factor <= 0 || factor.isNaN || factor.isInfinite) {
      return;
    }
    distance = _distance / factor;
  }

  /// Pans [target] parallel to the camera's image plane by [delta] viewport
  /// pixels scaled by [speed].
  void panScreenDelta(Vector2 delta, {double speed = 1.0}) {
    final cam = _resolveCamera();
    var unitsPerPixel = 0.01 * _currentDistance;
    if (cam != null) {
      final vh = cam.viewport.virtualSize.y;
      if (vh > 0) {
        unitsPerPixel = switch (cam.projection) {
          CameraProjection.perspective =>
            (2.0 *
                    _currentDistance *
                    math.tan((cam.fovY * degrees2Radians) * 0.5)) /
                vh,
          CameraProjection.orthographic =>
            (cam.orthographicHeight ?? cam.fovY) / vh,
        };
      }
    }

    _computeScreenAxes(_currentYaw, _currentPitch);
    final step = unitsPerPixel * speed;
    final dx = -_right.x * delta.x * step + _screenUp.x * delta.y * step;
    final dy = -_right.y * delta.x * step + _screenUp.y * delta.y * step;
    final dz = -_right.z * delta.x * step + _screenUp.z * delta.y * step;
    target.setValues(target.x + dx, target.y + dy, target.z + dz);
  }

  /// Frames [bounds] inside the active camera frustum with multiplicative
  /// [padding] (`>= 1.0`), snapping immediately unless [immediate] is `false`.
  void fitAabb(
    Aabb3 bounds, {
    double padding = 1.15,
    bool immediate = true,
  }) {
    final cx = (bounds.min.x + bounds.max.x) * 0.5;
    final cy = (bounds.min.y + bounds.max.y) * 0.5;
    final cz = (bounds.min.z + bounds.max.z) * 0.5;
    target.setValues(cx, cy, cz);

    final hx = (bounds.max.x - bounds.min.x) * 0.5;
    final hy = (bounds.max.y - bounds.min.y) * 0.5;
    final hz = (bounds.max.z - bounds.min.z) * 0.5;
    final radius = math.max(1e-3, math.sqrt(hx * hx + hy * hy + hz * hz));
    final paddedRadius = radius * math.max(1.0, padding);

    final cam = _resolveCamera();
    var aspect = 1.0;
    if (cam != null) {
      final vpSize = cam.viewport.virtualSize;
      if (vpSize.x > 0 && vpSize.y > 0) {
        aspect = vpSize.x / vpSize.y;
      }
    }

    if (cam != null && cam.projection == CameraProjection.orthographic) {
      final orthoHeight = (2.0 * paddedRadius) / math.min(1.0, aspect);
      cam.orthographicHeight = orthoHeight;
      distance = math.max(_distance, paddedRadius + math.max(0.0, cam.near));
    } else {
      final fovYRad = ((cam?.fovY ?? 60.0) * degrees2Radians).clamp(0.05, 3.0);
      final halfFovY = fovYRad * 0.5;
      final halfFovX = math.atan(math.tan(halfFovY) * aspect);
      final minHalfFov = math.min(halfFovY, halfFovX);
      final sinHalf = math.max(1e-4, math.sin(minHalfFov));
      distance = paddedRadius / sinHalf;
    }

    if (immediate) {
      snap();
    }
  }

  /// Immediately snaps the smoothed state to the desired orbit parameters and
  /// updates the camera.
  void snap() {
    _pitch = _pitch.clamp(minPitch, maxPitch);
    _distance = _distance.clamp(minDistance, maxDistance);
    _currentYaw = yaw;
    _currentPitch = _pitch;
    _currentDistance = _distance;
    _currentTarget.setFrom(target);
    final cam = _resolveCamera();
    if (cam != null) {
      _applyToCamera(cam);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pitch = _pitch.clamp(minPitch, maxPitch);
    _distance = _distance.clamp(minDistance, maxDistance);

    if (damping <= 0 || dt <= 0) {
      _currentYaw = yaw;
      _currentPitch = _pitch;
      _currentDistance = _distance;
      _currentTarget.setFrom(target);
    } else {
      final alpha = 1.0 - math.exp(-damping * dt);
      _currentYaw += (yaw - _currentYaw) * alpha;
      _currentPitch += (_pitch - _currentPitch) * alpha;
      _currentDistance += (_distance - _currentDistance) * alpha;
      _currentTarget.setValues(
        _currentTarget.x + (target.x - _currentTarget.x) * alpha,
        _currentTarget.y + (target.y - _currentTarget.y) * alpha,
        _currentTarget.z + (target.z - _currentTarget.z) * alpha,
      );
    }

    final cam = _resolveCamera();
    if (cam != null) {
      _applyToCamera(cam);
    }
  }

  void _computeHorizontalFrame() {
    final ref = _upAxis.z.abs() < 0.9 ? Vector3(0, 0, 1) : Vector3(0, -1, 0);
    _upAxis.crossInto(ref, _axisX);
    _axisX.normalize();
    _axisX.crossInto(_upAxis, _axisZ);
    _axisZ.normalize();
  }

  void _computeScreenAxes(double yawRad, double pitchRad) {
    _computeHorizontalFrame();
    final cosY = math.cos(yawRad);
    final sinY = math.sin(yawRad);
    final cosP = math.cos(pitchRad);
    final sinP = math.sin(pitchRad);

    final backX = cosP * (sinY * _axisX.x + cosY * _axisZ.x) + sinP * _upAxis.x;
    final backY = cosP * (sinY * _axisX.y + cosY * _axisZ.y) + sinP * _upAxis.y;
    final backZ = cosP * (sinY * _axisX.z + cosY * _axisZ.z) + sinP * _upAxis.z;

    _right
      ..setValues(
        _upAxis.y * backZ - _upAxis.z * backY,
        _upAxis.z * backX - _upAxis.x * backZ,
        _upAxis.x * backY - _upAxis.y * backX,
      )
      ..normalize();

    _screenUp
      ..setValues(
        backY * _right.z - backZ * _right.y,
        backZ * _right.x - backX * _right.z,
        backX * _right.y - backY * _right.x,
      )
      ..normalize();
  }

  void _applyToCamera(CameraComponent3D cam) {
    _computeHorizontalFrame();
    final cosY = math.cos(_currentYaw);
    final sinY = math.sin(_currentYaw);
    final cosP = math.cos(_currentPitch);
    final sinP = math.sin(_currentPitch);

    final dirX = cosP * (sinY * _axisX.x + cosY * _axisZ.x) + sinP * _upAxis.x;
    final dirY = cosP * (sinY * _axisX.y + cosY * _axisZ.y) + sinP * _upAxis.y;
    final dirZ = cosP * (sinY * _axisX.z + cosY * _axisZ.z) + sinP * _upAxis.z;

    cam.up = _upAxis;
    cam.target.setFrom(_currentTarget);
    cam.position.setValues(
      _currentTarget.x + dirX * _currentDistance,
      _currentTarget.y + dirY * _currentDistance,
      _currentTarget.z + dirZ * _currentDistance,
    );
  }
}
