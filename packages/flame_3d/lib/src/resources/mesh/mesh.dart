import 'package:flame_3d/resources.dart';

class Mesh {
  Mesh({required this.geometry, Material? material})
      : material = material ?? DefaultMaterial(texture: Texture.empty);

  Geometry geometry;

  Material material;
}
