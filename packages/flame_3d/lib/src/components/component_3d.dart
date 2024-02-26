import 'dart:ui';

import 'package:flame/components.dart' show Component, HasWorldReference;
import 'package:flame/game.dart' show FlameGame;
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

/// {@template component_3d}
/// [Component3D]s are the basic building blocks for a 3D [FlameGame].
///
/// It is a [Component] implementation that represents a 3D object that can be
/// freely moved around in 3D space, rotated, and scaled.
///
/// The [Component3D] class has no visual representation of its own (except in
/// debug mode). It is common, therefore, to derive from this class
/// and implement a specific rendering logic.
///
/// The base [Component3D] class can also be used as a container
/// for several other components. In this case, changing the position,
/// rotating or scaling the [Component3D] will affect the whole
/// group as if it was a single entity.
///
/// The main property of this class is the [transform] (which combines
/// the [position], [rotation], and [scale]). Thus, the [Component3D] can be
/// seen as an object in 3D space where you can change its perceived
/// visualization.
///
/// See the [MeshComponent] for a [Component3D] that has a visual representation
/// by using [Mesh]es
/// {@endtemplate}
class Component3D extends Component with HasWorldReference<World3D> {
  /// {@macro component_3d}
  Component3D({
    Vector3? position,
    Quaternion? rotation,
  }) : transform = Transform3D()
          ..position = position ?? Vector3.zero()
          ..rotation = rotation ?? Quaternion.euler(0, 0, 0)
          ..scale = Vector3.all(1);

  final Transform3D transform;

  /// The total transformation matrix for the component. This matrix combines
  /// translation, rotation and scale transforms into a single entity. The
  /// matrix is cached and gets recalculated only as necessary.
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

  /// The rotation of this component.
  NotifyingQuaternion get rotation => transform.rotation;
  set rotation(NotifyingQuaternion rotation) => transform.rotation = rotation;

  /// The scale factor of this component. The scale can be different along
  /// the X, Y and Z dimensions. A scale greater than 1 makes the component
  /// bigger along that axis, and less than 1 smaller. The scale can also be negative,
  /// which results in a mirror reflection along the corresponding axis.
  NotifyingVector3 get scale => transform.scale;
  set scale(Vector3 scale) => transform.scale = scale;

  /// Measure the distance (in parent's coordinate space) between this
  /// component's anchor and the [other] component's anchor.
  double distance(Component3D other) => position.distanceTo(other.position);

  @override
  void renderTree(Canvas canvas) {
    super.renderTree(canvas);
    if (!shouldCull(CameraComponent3D.currentCamera!)) {
      world.culled++;
      return;
    }

    // We set the priority to the distance between the camera and the object.
    // This ensures that our rendering is done in a specific order allowing for
    // alpha blending.
    //
    // Note(wolfen): we should optimize this in the long run it currently sucks.
    priority = -(CameraComponent3D.currentCamera!.position - position)
        .length
        .abs()
        .toInt();

    bind(world.graphics);
  }

  void bind(GraphicsDevice device) {}

  bool shouldCull(CameraComponent3D camera) {
    return camera.frustum.containsVector3(position);
  }
}
