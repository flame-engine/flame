import 'package:flame_3d/camera.dart';
import 'package:flame_3d/core.dart';
import 'package:meta/meta.dart';

class FirstPersonCamera extends CameraComponent3D {
  FirstPersonCamera({
    required this.following,
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
  });

  /// The point the camera should follow.
  Vector3 following;

  @override
  @mustCallSuper
  void update(double dt) {
    // Always set the camera's position to the following point.
    position.setFrom(following);

    // Compute the desired target to look at.
    target.setFrom(position + _getForwardDirection());
  }

  Vector3 _getForwardDirection() {
    final forward = Vector3(0, 0, -1)..applyQuaternion(rotation);
    return forward.normalized();
  }
}
