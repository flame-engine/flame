import 'package:flame_3d/camera.dart';
import 'package:flame_3d/core.dart';
import 'package:meta/meta.dart';

/// A [CameraComponent3D] whose eye sits on the [following] point and looks
/// along its [rotation].
class FirstPersonCamera({
  /// The point the camera should follow.
  required var Vector3 following,
  super.fovY,
  super.orthographicHeight,
  super.near,
  super.far,
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
  @override
  @mustCallSuper
  void update(double dt) {
    super.update(dt);

    // Always set the camera's position to the following point.
    position.setFrom(following);

    // Look one unit along the rotated forward direction.
    _forward
      ..setValues(0, 0, -1)
      ..applyQuaternion(rotation)
      ..normalize();
    target.setValues(
      position.x + _forward.x,
      position.y + _forward.y,
      position.z + _forward.z,
    );
  }

  final Vector3 _forward = Vector3.zero();
}
