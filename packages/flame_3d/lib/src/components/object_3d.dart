import 'dart:ui';

import 'package:flame/game.dart' show FlameGame;
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

/// {@template object_3d}
/// [Object3D]s are the basic building blocks for a 3D [FlameGame].
///
/// It is an object that is positioned in 3D space and can be bind to be
/// rendered by a [GraphicsDevice].
///
/// However, it has no visual representation of its own (except in
/// debug mode). It is common, therefore, to derive from this class
/// and implement a specific rendering logic.
///
/// See the [MeshComponent] for an [Object3D] that has a visual representation
/// using a [Mesh].
/// {@endtemplate}
abstract class Object3D extends Component3D {
  /// {@macro object_3d}
  Object3D({
    super.position,
    super.scale,
    super.rotation,
  });

  @override
  void renderTree(Canvas canvas) {
    super.renderTree(canvas);
    final camera = CameraComponent3D.currentCamera;
    assert(
      camera != null,
      '''Component is either not part of a World3D or the render is being called outside of the camera rendering''',
    );
    if (!shouldCull(camera!)) {
      world.culled++;
      return;
    }

    // We set the priority to the distance between the camera and the object.
    // This ensures that our rendering is done in a specific order allowing for
    // alpha blending.
    //
    // Note(wolfenrain): we should optimize this in the long run it currently
    // sucks.
    priority = -(CameraComponent3D.currentCamera!.position - position).length
        .abs()
        .toInt();

    bind(world.device);
  }

  void bind(GraphicsDevice device);

  bool shouldCull(CameraComponent3D camera) {
    return camera.frustum.containsVector3(position);
  }
}
