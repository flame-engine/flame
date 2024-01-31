import 'dart:ui';

import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

/// {@template mesh_component}
/// A [Component3D] that renders a [Mesh] at the [position] with the [rotation]
/// and [scale] applied.
///
/// This a commonly used subclass of [Component3D].
/// {@endtemplate}
class MeshComponent extends Component3D {
  /// {@macro mesh_component}
  MeshComponent({
    required Mesh mesh,
    super.position,
    super.rotation,
  }) : _mesh = mesh;

  /// {@macro mesh_component}
  ///
  /// Creates a mesh based on the [geometry] and [material].
  MeshComponent.geometry({
    required Geometry geometry,
    Material? material,
    Vector3? position,
    Quaternion? rotation,
  }) : this(
          position: position,
          rotation: rotation,
          mesh: Mesh(
            geometry: geometry,
            material: material ?? DefaultMaterial(texture: Texture.empty),
          ),
        );

  /// The mesh resource that holds the [geometry] and [material] to visualize.
  Mesh get mesh => _mesh;
  final Mesh _mesh;

  /// The geometry of the [mesh].
  ///
  /// You can change this at runtime by setting it to a different instance of
  /// [Geometry].
  Geometry get geometry => _mesh.geometry;
  set geometry(Geometry geometry) => _mesh.geometry = geometry;

  /// The material of the [mesh].
  ///
  /// You can change this at runtime by setting it to a different instance of
  /// [Material].
  Material get material => _mesh.material;
  set material(Material material) => _mesh.material = material;

  @override
  void renderTree(Canvas canvas) {
    super.renderTree(canvas);
    world.graphics.bindMesh(mesh, transformMatrix);
  }
}
