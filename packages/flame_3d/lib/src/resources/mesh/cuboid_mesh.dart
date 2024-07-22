import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

/// {@template cuboid_mesh}
/// Represents a Cuboid's geometry with a single surface.
/// {@endtemplate}
class CuboidMesh extends Mesh {
  /// {@macro cuboid_mesh}
  CuboidMesh({
    required Vector3 size,
    Material? material,
  }) {
    final Vector3(:x, :y, :z) = size / 2;

    final vertices = [
      // Face 1 (front)
      Vertex(
        position: Vector3(-x, -y, -z),
        texCoord: Vector2(0, 0),
        normal: Vector3(0, 0, -1),
      ),
      Vertex(
        position: Vector3(x, -y, -z),
        texCoord: Vector2(1, 0),
        normal: Vector3(0, 0, -1),
      ),
      Vertex(
        position: Vector3(x, y, -z),
        texCoord: Vector2(1, 1),
        normal: Vector3(0, 0, -1),
      ),
      Vertex(
        position: Vector3(-x, y, -z),
        texCoord: Vector2(0, 1),
        normal: Vector3(0, 0, -1),
      ),

      // Face 2 (back)
      Vertex(
        position: Vector3(-x, -y, z),
        texCoord: Vector2(0, 0),
        normal: Vector3(0, 0, 1),
      ),
      Vertex(
        position: Vector3(x, -y, z),
        texCoord: Vector2(1, 0),
        normal: Vector3(0, 0, 1),
      ),
      Vertex(
        position: Vector3(x, y, z),
        texCoord: Vector2(1, 1),
        normal: Vector3(0, 0, 1),
      ),
      Vertex(
        position: Vector3(-x, y, z),
        texCoord: Vector2(0, 1),
        normal: Vector3(0, 0, 1),
      ),

      // Face 3 (left)
      Vertex(
        position: Vector3(-x, -y, z),
        texCoord: Vector2(0, 0),
        normal: Vector3(-1, 0, 0),
      ),
      Vertex(
        position: Vector3(-x, -y, -z),
        texCoord: Vector2(1, 0),
        normal: Vector3(-1, 0, 0),
      ),
      Vertex(
        position: Vector3(-x, y, -z),
        texCoord: Vector2(1, 1),
        normal: Vector3(-1, 0, 0),
      ),
      Vertex(
        position: Vector3(-x, y, z),
        texCoord: Vector2(0, 1),
        normal: Vector3(-1, 0, 0),
      ),

      // Face 4 (right)
      Vertex(
        position: Vector3(x, -y, -z),
        texCoord: Vector2(0, 0),
        normal: Vector3(1, 0, 0),
      ),
      Vertex(
        position: Vector3(x, -y, z),
        texCoord: Vector2(1, 0),
        normal: Vector3(1, 0, 0),
      ),
      Vertex(
        position: Vector3(x, y, z),
        texCoord: Vector2(1, 1),
        normal: Vector3(1, 0, 0),
      ),
      Vertex(
        position: Vector3(x, y, -z),
        texCoord: Vector2(0, 1),
        normal: Vector3(1, 0, 0),
      ),

      // Face 5 (top)
      Vertex(
        position: Vector3(-x, y, -z),
        texCoord: Vector2(0, 0),
        normal: Vector3(0, 1, 0),
      ),
      Vertex(
        position: Vector3(x, y, -z),
        texCoord: Vector2(1, 0),
        normal: Vector3(0, 1, 0),
      ),
      Vertex(
        position: Vector3(x, y, z),
        texCoord: Vector2(1, 1),
        normal: Vector3(0, 1, 0),
      ),
      Vertex(
        position: Vector3(-x, y, z),
        texCoord: Vector2(0, 1),
        normal: Vector3(0, 1, 0),
      ),

      // Face 6 (bottom)
      Vertex(
        position: Vector3(-x, -y, z),
        texCoord: Vector2(0, 0),
        normal: Vector3(0, -1, 0),
      ),
      Vertex(
        position: Vector3(x, -y, z),
        texCoord: Vector2(1, 0),
        normal: Vector3(0, -1, 0),
      ),
      Vertex(
        position: Vector3(x, -y, -z),
        texCoord: Vector2(1, 1),
        normal: Vector3(0, -1, 0),
      ),
      Vertex(
        position: Vector3(-x, -y, -z),
        texCoord: Vector2(0, 1),
        normal: Vector3(0, -1, 0),
      ),
    ];

    final indices = [
      0, 1, 2, 2, 3, 0, // Face 1
      4, 5, 6, 6, 7, 4, // Face 2
      8, 9, 10, 10, 11, 8, // Face 3
      12, 13, 14, 14, 15, 12, // Face 4
      16, 17, 18, 18, 19, 16, // Face 5
      20, 21, 22, 22, 23, 20, // Face 6
    ];

    addSurface(
      Surface(
        vertices: vertices,
        indices: indices,
        material: material,
      ),
    );
  }
}
