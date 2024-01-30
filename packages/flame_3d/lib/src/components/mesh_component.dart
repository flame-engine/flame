import 'dart:ui';

import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

class MeshComponent extends Component3D {
  MeshComponent({
    required Mesh mesh,
    super.position,
    super.rotation,
  }) : _mesh = mesh;

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

  Mesh get mesh => _mesh;
  final Mesh _mesh;

  Geometry get geometry => _mesh.geometry;
  set geometry(Geometry geometry) => _mesh.geometry = geometry;

  Material get material => _mesh.material;
  set material(Material material) => _mesh.material = material;

  @override
  void renderTree(Canvas canvas) {
    super.renderTree(canvas);
    world.graphics.bindMesh(mesh, transformMatrix);
  }
}
