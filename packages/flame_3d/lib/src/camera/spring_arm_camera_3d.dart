import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/graphics.dart' show CullMode;

/// Collision-aware 3D spring-arm follow camera controller.
///
/// Tracks either [targetComponent] or [target] plus [socketOffset] at desired
/// distance [armLength], casts a ray through [World3D.raycast] toward the
/// desired camera eye, pulls the camera in immediately (with [probeRadius]
/// clearance) whenever geometry blocks line of sight, and recovers smoothly
/// outward when unobstructed.
class SpringArmCamera3D({
  CameraComponent3D? camera,
  World3D? world,
  var Component3D? targetComponent,
  Vector3? target,
  Vector3? socketOffset,
  Vector3? upAxis,
  double armLength = 5.0,
  var double minArmLength = 0.15,
  var double probeRadius = 0.25,
  var double recoverySpeed = 8.0,
  var double yaw = 0.0,
  var double pitch = 0.25,
  var bool Function(Object3D object)? collisionFilter,
  super.priority,
  super.key,
}) extends Component {
  this
    : assert(armLength > 0, 'armLength must be positive'),
      assert(minArmLength >= 0, 'minArmLength must be non-negative'),
      assert(probeRadius >= 0, 'probeRadius must be non-negative') {
    _armLength = armLength;
    _currentArmLength = armLength;
  }

  final CameraComponent3D? _explicitCamera = camera;
  final World3D? _explicitWorld = world;
  CameraComponent3D? _mountedCamera;
  World3D? _mountedWorld;

  /// Fallback world-space target point followed when [targetComponent] is
  /// `null`. Mutating this vector in place updates the followed point.
  final Vector3 target = target ?? Vector3.zero();

  /// World-space offset added to the followed target to form the spring-arm
  /// socket pivot (for example shoulder/head height `(0, 1.5, 0)`).
  final Vector3 socketOffset = socketOffset?.clone() ?? Vector3.zero();

  final Vector3 _upAxis = (upAxis?.clone() ?? Vector3(0, 1, 0))..normalize();

  late double _armLength;
  late double _currentArmLength;
  bool _isOccluded = false;

  /// Desired unobstructed boom length in world units.
  double get armLength => _armLength;
  set armLength(double value) {
    assert(value > 0, 'armLength must be positive');
    _armLength = value;
  }

  /// Current active boom length after collision pull-in and recovery.
  double get currentArmLength => _currentArmLength;

  /// Whether line of sight was occluded on the most recent [update].
  bool get isOccluded => _isOccluded;

  final Vector3 _pivot = Vector3.zero();
  final Vector3 _axisX = Vector3.zero();
  final Vector3 _axisZ = Vector3.zero();
  final Vector3 _armDir = Vector3.zero();
  final Ray _probeRay = Ray();

  /// Resolved [CameraComponent3D] driven by this controller.
  CameraComponent3D get camera {
    final resolved = _resolveCamera();
    if (resolved == null) {
      throw StateError(
        'SpringArmCamera3D requires a CameraComponent3D passed to its '
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

  World3D? _resolveWorld(CameraComponent3D? cam) {
    if (_explicitWorld != null) {
      return _explicitWorld;
    }
    if (cam?.world case final camWorld?) {
      return camWorld;
    }
    if (_mountedWorld != null) {
      return _mountedWorld;
    }
    for (final ancestor in ancestors()) {
      if (ancestor is World3D) {
        return _mountedWorld = ancestor;
      }
    }
    if (targetComponent case final followed?) {
      for (final ancestor in followed.ancestors()) {
        if (ancestor is World3D) {
          return _mountedWorld = ancestor;
        }
      }
    }
    return null;
  }

  @override
  void onMount() {
    super.onMount();
    _mountedCamera = null;
    _mountedWorld = null;
  }

  @override
  void onRemove() {
    _mountedCamera = null;
    _mountedWorld = null;
    super.onRemove();
  }

  @override
  void update(double dt) {
    super.update(dt);
    final cam = camera;
    final resolvedWorld = _resolveWorld(cam);

    if (targetComponent case final followed?) {
      final wm = followed.worldTransformMatrix.storage;
      _pivot.setValues(
        wm[12] + socketOffset.x,
        wm[13] + socketOffset.y,
        wm[14] + socketOffset.z,
      );
    } else {
      _pivot.setValues(
        target.x + socketOffset.x,
        target.y + socketOffset.y,
        target.z + socketOffset.z,
      );
    }

    _computeArmDirection();

    var allowedDistance = _armLength;
    _isOccluded = false;

    if (resolvedWorld != null) {
      _probeRay.origin.setFrom(_pivot);
      _probeRay.direction.setFrom(_armDir);
      final hit = resolvedWorld.raycast(
        _probeRay,
        maxDistance: _armLength + probeRadius,
        cullMode: CullMode.none,
        filter: _passesCollisionFilter,
      );
      if (hit != null) {
        _isOccluded = true;
        allowedDistance = math.max(
          minArmLength,
          math.min(_armLength, hit.distance - probeRadius),
        );
      }
    }

    if (allowedDistance <= _currentArmLength) {
      _currentArmLength = allowedDistance;
    } else if (recoverySpeed <= 0 || dt <= 0) {
      _currentArmLength = allowedDistance;
    } else {
      final alpha = 1.0 - math.exp(-recoverySpeed * dt);
      _currentArmLength += (allowedDistance - _currentArmLength) * alpha;
    }

    cam.up = _upAxis;
    cam.target.setFrom(_pivot);
    cam.position.setValues(
      _pivot.x + _armDir.x * _currentArmLength,
      _pivot.y + _armDir.y * _currentArmLength,
      _pivot.z + _armDir.z * _currentArmLength,
    );
  }

  bool _passesCollisionFilter(Object3D candidate) {
    if (targetComponent case final followed?) {
      if (identical(candidate, followed)) {
        return false;
      }
      for (final ancestor in candidate.ancestors()) {
        if (identical(ancestor, followed)) {
          return false;
        }
      }
    }
    final customFilter = collisionFilter;
    return customFilter == null || customFilter(candidate);
  }

  void _computeArmDirection() {
    final ref = _upAxis.z.abs() < 0.9 ? Vector3(0, 0, 1) : Vector3(0, -1, 0);
    _upAxis.crossInto(ref, _axisX);
    _axisX.normalize();
    _axisX.crossInto(_upAxis, _axisZ);
    _axisZ.normalize();

    final cosY = math.cos(yaw);
    final sinY = math.sin(yaw);
    final cosP = math.cos(pitch);
    final sinP = math.sin(pitch);

    _armDir
      ..setValues(
        cosP * (sinY * _axisX.x + cosY * _axisZ.x) + sinP * _upAxis.x,
        cosP * (sinY * _axisX.y + cosY * _axisZ.y) + sinP * _upAxis.y,
        cosP * (sinY * _axisX.z + cosY * _axisZ.z) + sinP * _upAxis.z,
      )
      ..normalize();
  }
}
