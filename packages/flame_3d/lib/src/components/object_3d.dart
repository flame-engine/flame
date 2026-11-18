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
/// It is an object that is positioned in 3D space and can be drawn by a
/// [RenderContext].
///
/// However, it has no visual representation of its own (except in
/// debug mode). It is common, therefore, to derive from this class
/// and implement a specific rendering logic.
///
/// See the [MeshComponent] for an [Object3D] that has a visual representation
/// using a [Mesh].
/// {@endtemplate}
abstract class Object3D({
  super.position,
  super.scale,
  super.rotation,
  super.children,

  /// Whether this object casts shadows, when the scene has a light that
  /// casts them (see [ShadowSettings]). It applies to this object's own
  /// draws, not to its children; the surfaces of materials that cast no
  /// shadows (see [Material.castsShadows]) cast none either way.
  var bool castsShadows = true,
  super.cameraMask,
}) extends Component3D {
  /// Whether an ancestor's AABB was fully inside the frustum, meaning
  /// children can skip their own frustum tests.
  static bool _ancestorFullyInside = false;

  @override
  void renderTree(Canvas canvas) {
    final world = worldRef;
    assert(
      world.isRendering,
      'Object3D is rendered outside of the rendering of its World3D',
    );
    final context = world.context;
    if ((cameraMask & context.cameraMask) == 0) {
      return;
    }
    // The frustum of the pass, computed once by the context.
    final frustum = context.frustum;
    RenderProfile.lap(RenderPhase.traversal);

    // If ancestor is inside, so are we, otherwise test.
    final cullResult = _ancestorFullyInside
        ? CullResult.inside
        : aabb.frustumCullTest(frustum);
    RenderProfile.lap(RenderPhase.culling);

    // Result is fully outside, skip children and self.
    if (cullResult == CullResult.outside) {
      return;
    }

    // Render children. If fully inside, children can skip frustum tests.
    final wasAncestorFullyInside = _ancestorFullyInside;
    if (cullResult == CullResult.inside) {
      _ancestorFullyInside = true;
    }
    super.renderTree(canvas);
    _ancestorFullyInside = wasAncestorFullyInside;
    RenderProfile.lap(RenderPhase.traversal);

    final visible = cullResult == CullResult.inside || isVisible(frustum);
    RenderProfile.lap(RenderPhase.culling);
    if (visible && (castsShadows || !context.isShadowPass)) {
      draw(context);
    }
  }

  /// Records the draws of this object into [context], see
  /// [RenderContext3D.drawMesh] and [RenderContext3D.drawSurface].
  ///
  /// It is called while the world is traversed; the recorded draws reach the
  /// GPU when the context is flushed at the end of the pass. When the scene
  /// has a light that casts shadows, the world is traversed a first time to
  /// render the shadow map, with the light's view as the camera (see
  /// [RenderContext3D.isShadowPass]); objects that do not [castsShadows] are
  /// not drawn then.
  void draw(RenderContext context);

  /// Whether this component itself should be drawn when its [aabb] is not
  /// fully inside the camera's [frustum] (the light's view in a shadow
  /// pass).
  ///
  /// The default implementation checks whether the world-space [aabb]
  /// intersects the frustum, so a partially visible component is drawn.
  bool isVisible(Frustum frustum) {
    return frustum.intersectsWithAabb3(aabb);
  }

  /// Intersects [worldRay] against this object's own geometry within
  /// [maxDistance], returning the closest [RayHit3D] or `null` when missed.
  ///
  /// Subclasses that draw meshes ([MeshComponent], `ModelComponent`,
  /// [LodMeshComponent], [InstancedGroup3D]) override this using `Surface.bvh`.
  RayHit3D? raycast(
    Ray worldRay, {
    double maxDistance = double.infinity,
    CullMode? cullMode,
  }) => null;
}
