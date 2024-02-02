import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

class PlaneMesh extends Mesh {
  PlaneMesh({
    required Vector2 size,
    Material? material,
  }) {
    final Vector2(:x, :y) = size / 2;

    final vertices = [
      Vertex(position: Vector3(-x, 0, -y), texCoord: Vector2(0, 0)),
      Vertex(position: Vector3(x, 0, -y), texCoord: Vector2(1, 0)),
      Vertex(position: Vector3(x, 0, y), texCoord: Vector2(1, 1)),
      Vertex(position: Vector3(-x, 0, y), texCoord: Vector2(0, 1)),
    ];
    addSurface(vertices, [0, 1, 2, 2, 3, 0], material: material);
  }
}
