import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/game.dart';
import 'package:flutter/widgets.dart';

/// {@template vertex}
/// Represents a vertex in 3D space.
///
/// A vertex consists out of space coordinates, UV/texture coordinates and a
/// color.
/// {@endtemplate}
@immutable
class Vertex {
  /// {@macro vertex}
  Vertex({
    required Vector3 position,
    required Vector2 texCoord,
    Vector3? normal,
    this.color = const Color(0xFFFFFFFF),
  })  : position = position.immutable,
        texCoord = texCoord.immutable,
        normal = (normal ?? Vector3.zero()).immutable,
        _storage = Float32List.fromList([
          ...position.storage,
          ...texCoord.storage,
          // `TODO`(wolfen): uhh normals fuck shit up, I should read up on it
          // ...(normal ?? Vector3.zero()).storage,
          ...color.storage,
        ]);

  Float32List get storage => _storage;
  final Float32List _storage;

  /// The position of the vertex in 3D space.
  final ImmutableVector3 position;

  /// The UV coordinates of the texture to map.
  final ImmutableVector2 texCoord;

  /// The normal vector of the vertex.
  final ImmutableVector3 normal;

  /// The color on the vertex.
  final Color color;

  @override
  bool operator ==(Object other) =>
      other is Vertex &&
      position == other.position &&
      texCoord == other.texCoord &&
      normal == other.normal &&
      color == other.color;

  @override
  int get hashCode => Object.hashAll([position, texCoord, normal, color]);
}

typedef ImmutableVector2 = ({double x, double y});
typedef ImmutableVector3 = ({double x, double y, double z});
typedef ImmutableVector4 = ({double x, double y, double z, double w});

extension on Vector2 {
  ImmutableVector2 get immutable => (x: x, y: y);
}

extension on Vector3 {
  ImmutableVector3 get immutable => (x: x, y: y, z: z);
}

extension on Vector4 {
  ImmutableVector4 get immutable => (x: x, y: y, z: z, w: w);
}

extension on Color {
  List<double> get storage =>
      Float32List.fromList([red / 255, green / 255, blue / 255, opacity]);
}
