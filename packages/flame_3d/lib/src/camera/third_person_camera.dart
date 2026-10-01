import 'package:flame_3d/camera.dart';
import 'package:flame_3d/core.dart';
import 'package:meta/meta.dart';

class ThirdPersonCamera({
  /// The point the camera should follow.
  required var Vector3 following,
  var double _distance = 5.0,

  /// Damping factor for smoothing out rotation and position changes.
  ///
  /// If the value is `1`, no damping is applied.
  var double followDamping = 1.0,
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
}) extends CameraComponent3D {
  /// The distance the camera should maintain from the `following` point.
  double get distance => _distance;
  set distance(double value) => _distance = value.clamp(0.1, double.infinity);
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
