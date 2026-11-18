import 'dart:math' as math;

import 'package:flame/geometry.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

/// {@template cylinder_mesh}
/// A cylinder centered on the origin along the y-axis, with a single surface:
/// the side and the two caps, each with its own vertices and normals.
/// {@endtemplate}
class CylinderMesh({
  /// The radius of the cylinder.
  required final double radius,

  /// The full height of the cylinder along the y-axis.
  required final double height,
  int segments = 16,
  Material? material,
}) extends Mesh {
  /// {@macro cylinder_mesh}
  this {
    final vertices = <Vertex>[];
    final indices = <int>[];
    final halfHeight = height / 2.0;

    // Side: a top and a bottom vertex at each angle, with radial normals.
    for (var i = 0; i <= segments; i++) {
      final theta = i * tau / segments;
      final cos = math.cos(theta);
      final sin = math.sin(theta);
      final normal = Vector3(cos, 0, sin);
      final u = i / segments;
      vertices
        ..add(
          Vertex(
            position: Vector3(radius * cos, halfHeight, radius * sin),
            texCoord: Vector2(u, 0),
            normal: normal,
          ),
        )
        ..add(
          Vertex(
            position: Vector3(radius * cos, -halfHeight, radius * sin),
            texCoord: Vector2(u, 1),
            normal: normal,
          ),
        );
    }
    // Counter-clockwise seen from outside, so front faces point outwards.
    for (var i = 0; i < segments; i++) {
      final top = i * 2;
      final bottom = top + 1;
      indices.addAll([top, top + 2, bottom, bottom, top + 2, bottom + 2]);
    }

    void addCap(double y, double normalY) {
      final center = vertices.length;
      final normal = Vector3(0, normalY, 0);
      vertices.add(
        Vertex(
          position: Vector3(0, y, 0),
          texCoord: Vector2(0.5, 0.5),
          normal: normal,
        ),
      );
      for (var i = 0; i <= segments; i++) {
        final theta = i * tau / segments;
        final cos = math.cos(theta);
        final sin = math.sin(theta);
        vertices.add(
          Vertex(
            position: Vector3(radius * cos, y, radius * sin),
            texCoord: Vector2((1 + cos) * 0.5, (1 + sin) * 0.5),
            normal: normal,
          ),
        );
      }
      for (var i = 0; i < segments; i++) {
        final ring = center + 1 + i;
        indices.addAll(
          normalY > 0 ? [center, ring + 1, ring] : [center, ring, ring + 1],
        );
      }
    }

    addCap(halfHeight, 1);
    addCap(-halfHeight, -1);

    addSurface(
      Surface(
        vertices: vertices,
        indices: indices,
        material: material,
      ),
    );
  }
}
