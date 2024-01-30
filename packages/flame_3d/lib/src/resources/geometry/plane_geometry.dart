import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

class PlaneGeometry extends Geometry {
  PlaneGeometry({required Vector2 size}) {
    final e = size / 2;
    setVertices([
      Vertex(position: Vector3(-e.x, 0, -e.y), texCoords: Vector2(0, 0)),
      Vertex(position: Vector3(e.x, 0, -e.y), texCoords: Vector2(1, 0)),
      Vertex(position: Vector3(e.x, 0, e.y), texCoords: Vector2(1, 1)),
      Vertex(position: Vector3(-e.x, 0, e.y), texCoords: Vector2(0, 1)),
    ]);

    setIndices([0, 1, 2, 2, 3, 0]);
  }
}
