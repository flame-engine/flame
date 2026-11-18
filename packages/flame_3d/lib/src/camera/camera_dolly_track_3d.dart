import 'package:flame/components.dart';
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/resources.dart';

/// Moves a [CameraComponent3D] smoothly along an [eyeSpline] and an optional
/// [lookAtSpline] or fixed [lookAtTarget], with normalized [progress] in
/// `[0..1]`, [duration], [loop], and smooth cubic Hermite easing.
class CameraDollyTrack3D({
  required final CatmullRomSpline3D eyeSpline,
  final CatmullRomSpline3D? lookAtSpline,
  Vector3? lookAtTarget,
  CameraComponent3D? camera,
  var double duration = 5.0,
  var bool loop = false,
  var bool cubicEasing = true,
  var bool playing = true,
  var void Function()? onComplete,
  super.priority,
  super.key,
}) extends Component {
  this : assert(duration > 0, 'duration must be positive') {
    if (_explicitCamera != null) {
      _applyToCamera(_explicitCamera);
    }
  }

  final CameraComponent3D? _explicitCamera = camera;
  CameraComponent3D? _mountedCamera;

  /// Optional fixed world-space point observed while traversing [eyeSpline]
  /// when [lookAtSpline] is `null`. When both are `null`, the camera looks
  /// forward along the spline tangent.
  Vector3? lookAtTarget = lookAtTarget?.clone();

  double _elapsed = 0.0;
  double _progress = 0.0;
  bool _completed = false;
  final Vector3 _tangent = Vector3.zero();

  /// Normalized track traversal progress in `[0..1]`.
  double get progress => _progress;
  set progress(double value) {
    _progress = value.clamp(0.0, 1.0);
    _elapsed = _progress * duration;
    _completed = !loop && _progress >= 1.0;
    final cam = _resolveCamera();
    if (cam != null) {
      _applyToCamera(cam);
    }
  }

  /// Whether a non-looping dolly traversal has reached the end of the track.
  bool get isCompleted => _completed;

  /// Resolved [CameraComponent3D] driven by this dolly track.
  CameraComponent3D get camera {
    final resolved = _resolveCamera();
    if (resolved == null) {
      throw StateError(
        'CameraDollyTrack3D requires a CameraComponent3D passed to its '
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

  /// Resets [progress] to `0` and restarts playback.
  void reset() {
    _elapsed = 0.0;
    _progress = 0.0;
    _completed = false;
    final cam = _resolveCamera();
    if (cam != null) {
      _applyToCamera(cam);
    }
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

  @override
  void update(double dt) {
    super.update(dt);
    final cam = _resolveCamera();
    if (!playing || _completed) {
      return;
    }

    if (dt > 0) {
      _elapsed += dt;
      if (loop) {
        _progress = (_elapsed / duration) % 1.0;
      } else if (_elapsed >= duration) {
        _elapsed = duration;
        _progress = 1.0;
        _completed = true;
      } else {
        _progress = (_elapsed / duration).clamp(0.0, 1.0);
      }
    }

    if (cam != null) {
      _applyToCamera(cam);
    }

    if (_completed) {
      onComplete?.call();
    }
  }

  void _applyToCamera(CameraComponent3D cam) {
    final t = _progress.clamp(0.0, 1.0);
    // Smooth cubic Hermite (`smoothstep`: `3t^2 - 2t^3`) when enabled.
    final eased = cubicEasing ? t * t * (3.0 - 2.0 * t) : t;

    eyeSpline.samplePoint(eased, out: cam.position);

    if (lookAtSpline case final targetSpline?) {
      targetSpline.samplePoint(eased, out: cam.target);
    } else if (lookAtTarget case final fixedTarget?) {
      cam.target.setFrom(fixedTarget);
    } else {
      eyeSpline.sampleTangent(eased, out: _tangent);
      cam.target.setValues(
        cam.position.x + _tangent.x,
        cam.position.y + _tangent.y,
        cam.position.z + _tangent.z,
      );
    }
  }
}
