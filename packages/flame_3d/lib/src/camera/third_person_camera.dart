import 'package:flame_3d/camera.dart';
import 'package:flame_3d/core.dart';
import 'package:meta/meta.dart';

/// A [CameraComponent3D] that orbits the [following] point at [distance],
/// behind it along its [rotation], and always looks at it.
class ThirdPersonCamera({
  /// The point the camera should follow.
  required var Vector3 following,
  var double _distance = 5.0,

  /// Damping factor for smoothing out rotation and position changes.
  ///
  /// Each update moves the camera `followDamping * dt` of the way from its
  /// position to the desired one.
  var double followDamping = 1.0,
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
  /// The distance the camera should maintain from the `following` point.
  double get distance => _distance;
  set distance(double value) => _distance = value.clamp(0.1, double.infinity);

  @override
  @mustCallSuper
  void update(double dt) {
    super.update(dt);

    // Compute the desired position based on the rotation and distance.
    _desired
      ..setValues(0, 0, -1)
      ..applyQuaternion(rotation)
      ..normalize()
      ..scale(-distance)
      ..add(following);

    // Smoothly interpolate the camera's position toward the desired position.
    final t = followDamping * dt;
    position.setValues(
      position.x + (_desired.x - position.x) * t,
      position.y + (_desired.y - position.y) * t,
      position.z + (_desired.z - position.z) * t,
    );

    // Always look at the following point.
    target.setFrom(following);
  }

  final Vector3 _desired = Vector3.zero();
}
