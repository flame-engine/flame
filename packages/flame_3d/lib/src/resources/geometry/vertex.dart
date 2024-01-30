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
    Color color = const Color(0xFFFFFFFF),
  }) : color = Vector4(
          color.red / 255,
          color.green / 255,
          color.blue / 255,
          color.opacity,
        );

  /// The position of the vertex in 3D space.
  final Vector3 position;

  /// The UV coordinates of the texture to map.
  final Vector2 texCoords;

  /// The color on the vertex.
  final Vector4 color;
}
