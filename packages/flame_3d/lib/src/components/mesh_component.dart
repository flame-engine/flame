import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

/// {@template mesh_component}
/// An [Object3D] that renders a [Mesh] at the [position] with the [rotation]
/// and [scale] applied.
///
/// This is a commonly used subclass of [Object3D].
/// {@endtemplate}
class MeshComponent({
  required final Mesh _mesh,
  super.position,
  super.scale,
  super.rotation,
  super.children,
}) extends Object3D {
  /// The mesh resource.
  Mesh get mesh => _mesh;
  @override
  Aabb3? computeLocalAabb() => mesh.aabb;

  @override
  void submit(RenderContext3D context) {
    context.submitMesh(mesh, worldTransformMatrix);
  }
}
