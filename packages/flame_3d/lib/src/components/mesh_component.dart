import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d/src/camera/camera_component_3d.dart';

/// {@template mesh_component}
/// An [Object3D] that renders a [Mesh] at the [position] with the [rotation]
/// and [scale] applied.
///
/// This is a commonly used subclass of [Object3D].
/// {@endtemplate}
class MeshComponent extends Object3D {
  /// {@macro mesh_component}
  MeshComponent({
    required Mesh mesh,
    super.position,
    super.scale,
    super.rotation,
    super.children,
  }) : _mesh = mesh;

  /// The mesh resource.
  Mesh get mesh => _mesh;
  final Mesh _mesh;

  @override
  Aabb3? computeLocalAabb() => mesh.aabb;

  @override
  void draw(covariant RenderContext3D context) {
    context
      ..model.setFrom(worldTransformMatrix)
      ..drawMesh(mesh);
  }

  @override
  bool shouldCull(CameraComponent3D camera) {
    return camera.frustum.intersectsWithAabb3(aabb);
  }
}
