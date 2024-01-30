import 'package:flame/components.dart' show Component, HasWorldReference;
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/game.dart';

class Component3D extends Component with HasWorldReference<World3D> {
  Component3D({
    Vector3? position,
    Quaternion? rotation,
  }) : transform = Transform3D()
          ..position = position ?? Vector3.zero()
          ..rotation = rotation ?? Quaternion.euler(0, 0, 0)
          ..scale = Vector3.all(1);

  final Transform3D transform;

  Matrix4 get transformMatrix => transform.transformMatrix;

  /// The position of this component's anchor on the screen.
  NotifyingVector3 get position => transform.position;
  set position(Vector3 position) => transform.position = position;

  /// X position of this component's anchor on the screen.
  double get x => transform.x;
  set x(double x) => transform.x = x;

  /// Y position of this component's anchor on the screen.
  double get y => transform.y;
  set y(double y) => transform.y = y;

  /// Z position of this component's anchor on the screen.
  double get z => transform.z;
  set z(double z) => transform.z = z;

  NotifyingQuaternion get rotation => transform.rotation;
  set rotation(NotifyingQuaternion rotation) => transform.rotation = rotation;

  /// The scale factor of this component. The scale can be different along
  /// the X, Y and Z dimensions. A scale greater than 1 makes the component
  /// bigger, and less than 1 smaller. The scale can also be negative,
  /// which results in a mirror reflection along the corresponding axis.
  NotifyingVector3 get scale => transform.scale;
  set scale(Vector3 scale) => transform.scale = scale;
}
