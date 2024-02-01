import 'dart:ui';

import 'package:flame_3d/game.dart';

/// {@template vertex}
/// Represents a vertex in 3D space.
///
/// A vertex consists out of space coordinates, UV/texture coordinates and a
/// color.
/// {@endtemplate}
class Vertex {
  /// {@macro vertex}
  Vertex({
    required this.position,
    required this.texCoords,
    Vector3? normal,
    this.color = const Color(0xFFFFFFFF),
  }) : normal = normal ?? Vector3.zero();

  /// The position of the vertex in 3D space.
  final Vector3 position;

  /// The UV coordinates of the texture to map.
  final Vector2 texCoords;

  /// The normal vector of the vertex.
  final Vector3 normal;

  /// The color on the vertex.
  final Color color;
}
