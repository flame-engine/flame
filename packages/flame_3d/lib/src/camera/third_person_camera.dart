import 'package:flame_3d/camera.dart';
import 'package:flame_3d/core.dart';
import 'package:meta/meta.dart';

class ThirdPersonCamera extends CameraComponent3D {
  ThirdPersonCamera({
    required this.following,
    double distance = 5.0,
    this.followDamping = 1.0,
    super.fovY,
    super.position,
    super.rotation,
    super.up,
    super.projection,
    super.world,
    super.viewport,
    super.viewfinder,
    super.backdrop,
    super.hudComponents,
  }) : _distance = distance;

  /// The point the camera should follow.
  Vector3 following;

  /// The distance the camera should maintain from the `following` point.
  double get distance => _distance;
  set distance(double value) => _distance = value.clamp(0.1, double.infinity);
  double _distance;

  /// Damping factor for smoothing out rotation and position changes.
  ///
  /// If the value is `1`, no damping is applied.
  double followDamping;

  @override
  @mustCallSuper
  void update(double dt) {
    // Compute the desired position based on the rotation and distance.
    final desiredPosition = following + _getRotatedOffset();

    // Smoothly interpolate the camera's position toward the desired position.
    position = position + (desiredPosition - position) * (followDamping * dt);

    // Always look at the following point.
    target.setFrom(following);
  }

  Vector3 _getRotatedOffset() {
    final forward = Vector3(0, 0, -1)..applyQuaternion(rotation);
    return forward.normalized() * -distance;
  }
}
