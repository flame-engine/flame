import 'dart:ui';

import 'package:flame/game.dart' show FlameGame;
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/extensions.dart';
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
    super.children,
  });

  /// Whether an ancestor's AABB was fully inside the frustum, meaning
  /// children can skip their own frustum tests.
  static bool _ancestorFullyInside = false;

  @override
  void renderTree(Canvas canvas) {
    final camera = CameraComponent3D.currentCamera;
    assert(
      camera != null,
      '''Component is either not part of a World3D or the render is being called outside of the camera rendering''',
    );

    // If ancestor is inside, so are we, otherwise test.
    final cullResult = _ancestorFullyInside
        ? CullResult.inside
        : aabb.frustumCullTest(camera!.frustum);

    // Result is fully outside, skip children and self.
    if (cullResult == CullResult.outside) {
      world.culled++;
      return;
    }

    // Render children. If fully inside, children can skip frustum tests.
    final wasAncestorFullyInside = _ancestorFullyInside;
    if (cullResult == CullResult.inside) {
      _ancestorFullyInside = true;
    }
    super.renderTree(canvas);
    _ancestorFullyInside = wasAncestorFullyInside;

    if (cullResult == CullResult.inside || shouldCull(camera!)) {
      // We set the priority to the distance between the camera and the object.
      // This ensures that our rendering is done in a specific order allowing
      // for alpha blending.
      //
      // Note(wolfenrain): we should optimize this in the long run it currently
      // sucks.
      priority = -(CameraComponent3D.currentCamera!.position - position).length
          .abs()
          .toInt();

      bind(world.device);
    } else {
      world.culled++;
    }
  }

  void bind(GraphicsDevice device);

  bool shouldCull(CameraComponent3D camera) {
    return camera.frustum.containsVector3(position);
  }
}
