import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d/src/camera/camera_component_3d.dart';
import 'package:flame_3d/src/graphics/graphics_device.dart';

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
  }) : _mesh = mesh;

  /// The mesh resource.
  Mesh get mesh => _mesh;
  final Mesh _mesh;

  Aabb3 get aabb => _aabb
    ..setFrom(mesh.aabb)
    ..transform(transformMatrix);
  final Aabb3 _aabb = Aabb3();

  @override
  void bind(GraphicsDevice device) {
    world.device
      ..model.setFrom(transformMatrix)
      ..bindMesh(mesh);
  }

  @override
  bool shouldCull(CameraComponent3D camera) {
    return camera.frustum.intersectsWithAabb3(aabb);
  }
}
