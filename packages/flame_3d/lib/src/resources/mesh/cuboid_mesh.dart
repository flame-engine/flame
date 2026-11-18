import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

/// {@template cuboid_mesh}
/// Represents a Cuboid's geometry with a single surface.
/// {@endtemplate}
class CuboidMesh({
  required Vector3 size,
  Material? material,
  bool useFaceNormals = true,
}) extends Mesh {
  /// {@macro cuboid_mesh}
  this {
    final Vector3(:x, :y, :z) = size / 2;

    Vertex vertex({
      required Vector3 position,
      required Vector2 texCoord,
      required Vector3 normal,
    }) {
      return Vertex(
        position: position,
        texCoord: texCoord,
        normal: useFaceNormals ? normal : null,
      );
    }

    final vertices = [
      // Face 1 (front)
      vertex(
        position: Vector3(-x, -y, -z),
        texCoord: Vector2(0, 0),
        normal: Vector3(0, 0, -1),
      ),
      vertex(
        position: Vector3(x, -y, -z),
        texCoord: Vector2(1, 0),
        normal: Vector3(0, 0, -1),
      ),
      vertex(
        position: Vector3(x, y, -z),
        texCoord: Vector2(1, 1),
        normal: Vector3(0, 0, -1),
      ),
      vertex(
        position: Vector3(-x, y, -z),
        texCoord: Vector2(0, 1),
        normal: Vector3(0, 0, -1),
      ),

      // Face 2 (back)
      vertex(
        position: Vector3(-x, -y, z),
        texCoord: Vector2(0, 0),
        normal: Vector3(0, 0, 1),
      ),
      vertex(
        position: Vector3(x, -y, z),
        texCoord: Vector2(1, 0),
        normal: Vector3(0, 0, 1),
      ),
      vertex(
        position: Vector3(x, y, z),
        texCoord: Vector2(1, 1),
        normal: Vector3(0, 0, 1),
      ),
      vertex(
        position: Vector3(-x, y, z),
        texCoord: Vector2(0, 1),
        normal: Vector3(0, 0, 1),
      ),

      // Face 3 (left)
      vertex(
        position: Vector3(-x, -y, z),
        texCoord: Vector2(0, 0),
        normal: Vector3(-1, 0, 0),
      ),
      vertex(
        position: Vector3(-x, -y, -z),
        texCoord: Vector2(1, 0),
        normal: Vector3(-1, 0, 0),
      ),
      vertex(
        position: Vector3(-x, y, -z),
        texCoord: Vector2(1, 1),
        normal: Vector3(-1, 0, 0),
      ),
      vertex(
        position: Vector3(-x, y, z),
        texCoord: Vector2(0, 1),
        normal: Vector3(-1, 0, 0),
      ),

      // Face 4 (right)
      vertex(
        position: Vector3(x, -y, -z),
        texCoord: Vector2(0, 0),
        normal: Vector3(1, 0, 0),
      ),
      vertex(
        position: Vector3(x, -y, z),
        texCoord: Vector2(1, 0),
        normal: Vector3(1, 0, 0),
      ),
      vertex(
        position: Vector3(x, y, z),
        texCoord: Vector2(1, 1),
        normal: Vector3(1, 0, 0),
      ),
      vertex(
        position: Vector3(x, y, -z),
        texCoord: Vector2(0, 1),
        normal: Vector3(1, 0, 0),
      ),

      // Face 5 (top)
      vertex(
        position: Vector3(-x, y, -z),
        texCoord: Vector2(0, 0),
        normal: Vector3(0, 1, 0),
      ),
      vertex(
        position: Vector3(x, y, -z),
        texCoord: Vector2(1, 0),
        normal: Vector3(0, 1, 0),
      ),
      vertex(
        position: Vector3(x, y, z),
        texCoord: Vector2(1, 1),
        normal: Vector3(0, 1, 0),
      ),
      vertex(
        position: Vector3(-x, y, z),
        texCoord: Vector2(0, 1),
        normal: Vector3(0, 1, 0),
      ),

      // Face 6 (bottom)
      vertex(
        position: Vector3(-x, -y, z),
        texCoord: Vector2(0, 0),
        normal: Vector3(0, -1, 0),
      ),
      vertex(
        position: Vector3(x, -y, z),
        texCoord: Vector2(1, 0),
        normal: Vector3(0, -1, 0),
      ),
      vertex(
        position: Vector3(x, -y, -z),
        texCoord: Vector2(1, 1),
        normal: Vector3(0, -1, 0),
      ),
      vertex(
        position: Vector3(-x, -y, -z),
        texCoord: Vector2(0, 1),
        normal: Vector3(0, -1, 0),
      ),
    ];

    // Counter-clockwise seen from outside, so front faces point outwards.
    final indices = [
      0, 2, 1, 2, 0, 3, // Face 1
      4, 5, 6, 6, 7, 4, // Face 2
      8, 10, 9, 10, 8, 11, // Face 3
      12, 14, 13, 14, 12, 15, // Face 4
      16, 18, 17, 18, 16, 19, // Face 5
      20, 22, 21, 22, 20, 23, // Face 6
    ];

    addSurface(
      Surface(
        vertices: vertices,
        indices: indices,
        material: material,
      ),
    );
  }

  /// The full size of the cuboid along each axis.
  final Vector3 size = size.asUnmodifiableView();
}
