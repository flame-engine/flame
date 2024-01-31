import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

class Mesh extends Resource<void> {
  Mesh({required this.geometry, Material? material})
      : material = material ?? DefaultMaterial(texture: Texture.empty),
        super(null);

  Geometry geometry;

  Material material;

  void bind(GraphicsDevice device) {}
}
