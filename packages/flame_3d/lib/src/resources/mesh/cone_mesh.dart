import 'dart:math';

import 'package:flame/geometry.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/resources.dart';

/// A conical mesh, with base on the x-z plane, centered origin; and tip
/// pointing upwards parallel to the y-axis.
///
/// The default texture mapping follows the standard arrangement of the circular
/// base on the top left quadrant and the flattened side on the bottom half.
class ConeMesh extends Mesh {
  /// Creates a conical mesh with a circular base of radius [radius] on the x-z
  /// plane and a height of [height] pointing upwards parallel to the y-axis.
  ///
  /// You can optionally specify the number of segments used for the
  /// triangulation (the higher, the more "high-res" the cone will be).
  ConeMesh({
    required double radius,
    required double height,
    required Material material,
    int segments = 32,
  }) {
    _addBaseSurface(
      radius: radius,
      material: material,
      segments: segments,
    );
    _addSideSurface(
      radius: radius,
      height: height,
      material: material,
      segments: segments,
    );
  }

  void _addBaseSurface({
    required double radius,
    required Material material,
    required int segments,
  }) {
    final vertices = <Vertex>[];
    final indices = <int>[];

    // Texture mapping: circle radius 0.25 in UV
    const centerV = 0.75;

    // Base center
    vertices.add(
      Vertex(position: Vector3.zero(), texCoord: Vector2(0.5, centerV)),
    );

    // Base triangulation
    for (var i = 0; i < segments; i++) {
      final theta = tau * i / segments;
      final x = radius * cos(theta);
      final z = radius * sin(theta);
      final u = 0.5 + 0.25 * cos(theta);
      final v = centerV + 0.25 * sin(theta);
      vertices.add(
        Vertex(position: Vector3(x, 0, z), texCoord: Vector2(u, v)),
      );
    }

    for (var i = 0; i < segments; i++) {
      indices.addAll([0, i + 1, ((i + 1) % segments) + 1]);
    }

    addSurface(
      Surface(
        vertices: vertices,
        indices: indices,
        material: material,
      ),
    );
  }

  void _addSideSurface({
    required double radius,
    required double height,
    required Material material,
    required int segments,
  }) {
    final vertices = <Vertex>[];
    final indices = <int>[];

    // Texture mapping: base edge along arc in upper half
    const centerV = 0.75;
    const tipV = 0.25;

    // Tip
    vertices.add(
      Vertex(position: Vector3(0, height, 0), texCoord: Vector2(0.5, tipV)),
    );

    // Side triangulation
    for (var i = 0; i < segments; i++) {
      final theta = tau * i / segments;
      final x = radius * cos(theta);
      final z = radius * sin(theta);
      final u = i / segments;
      vertices.add(
        Vertex(position: Vector3(x, 0, z), texCoord: Vector2(u, centerV)),
      );
    }

    for (var i = 0; i < segments; i++) {
      indices.addAll([0, i + 1, ((i + 1) % segments) + 1]);
    }

    addSurface(
      Surface(
        vertices: vertices,
        indices: indices,
        material: material,
      ),
    );
  }
}
