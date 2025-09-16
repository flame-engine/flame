import 'dart:typed_data';
import 'dart:ui' show Color;

import 'package:flame_3d/game.dart';
import 'package:meta/meta.dart';

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
    this.color = const Color(0xFFFFFFFF),
    Vector3? normal,
    Vector4? joints,
    Vector4? weights,
  }) : position = position.immutable,
       texCoord = texCoord.immutable,
       normal = normal?.immutable,
       joints = joints?.immutable,
       weights = weights?.immutable,
       _storage = Float32List.fromList([
         ...position.storage, // 1, 2, 3
         ...texCoord.storage, // 4, 5
         ...[color.r, color.g, color.b, color.a], // 6, 7, 8, 9
         ...(normal ?? Vector3.zero()).storage, // 10, 11, 12
         ...(joints ?? Vector4.zero()).storage, // 13, 14, 15, 16
         ...(weights ?? Vector4.zero()).storage, // 17, 18, 19, 20
       ]);

  Float32List get storage => _storage;
  final Float32List _storage;

  /// The position of the vertex in 3D space.
  final ImmutableVector3 position;

  /// The UV coordinates of the texture to map.
  final ImmutableVector2 texCoord;

  /// The normal vector of the vertex.
  final ImmutableVector3? normal;

  /// The joints of the vertex.
  final ImmutableVector4? joints;

  /// The weights of the vertex.
  final ImmutableVector4? weights;

  /// The color on the vertex.
  final Color color;

  @override
  bool operator ==(Object other) =>
      other is Vertex &&
      position == other.position &&
      texCoord == other.texCoord &&
      normal == other.normal &&
      color == other.color &&
      joints == other.joints &&
      weights == other.weights;

  @override
  int get hashCode => Object.hashAll([
    position,
    texCoord,
    normal,
    color,
    joints,
    weights,
  ]);

  Vertex copyWith({
    Vector3? position,
    Vector2? texCoord,
    Vector3? normal,
    Color? color,
    Vector4? joints,
    Vector4? weights,
  }) {
    // TODO(wolfenrain): optimize this.
    return Vertex(
      position: position ?? this.position.mutable,
      texCoord: texCoord ?? this.texCoord.mutable,
      normal: normal ?? this.normal?.mutable,
      color: color ?? this.color,
      joints: joints ?? this.joints?.mutable,
      weights: weights ?? this.weights?.mutable,
    );
  }

  static List<Vector3> calculateVertexNormals(
    List<Vector3> vertices,
    List<int> indices,
  ) {
    final normals = List.filled(vertices.length, Vector3.zero());
    for (var i = 0; i < indices.length; i += 3) {
      final i0 = indices[i];
      final i1 = indices[i + 1];
      final i2 = indices[i + 2];

      final v0 = vertices[i0];
      final v1 = vertices[i1];
      final v2 = vertices[i2];

      final edge1 = v1 - v0;
      final edge2 = v2 - v0;
      final faceNormal = edge1.cross(edge2)..normalize();

      normals[i0] += faceNormal;
      normals[i1] += faceNormal;
      normals[i2] += faceNormal;
    }
    for (final normal in normals) {
      normal.normalize();
    }
    return normals;
  }
}
