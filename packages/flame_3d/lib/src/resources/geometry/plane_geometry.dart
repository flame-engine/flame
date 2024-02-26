import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

/// {@template plane_geometry}
/// Creates an 2D plane's geometry.
/// {@endtemplate}
class PlaneGeometry extends Geometry {
  /// {@macro plane_geometry}
  PlaneGeometry({required Vector2 size}) : super(indices: [0, 1, 2, 2, 3, 0]) {
    final Vector2(:x, :y) = size / 2;

    setVertices([
      Vertex(position: Vector3(-x, 0, -y), texCoord: Vector2(0, 0)),
      Vertex(position: Vector3(x, 0, -y), texCoord: Vector2(1, 0)),
      Vertex(position: Vector3(x, 0, y), texCoord: Vector2(1, 1)),
      Vertex(position: Vector3(-x, 0, y), texCoord: Vector2(0, 1)),
    ]);
  }
}
