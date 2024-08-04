import 'dart:math' as math;

import 'package:flame/geometry.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

class CylinderMesh extends Mesh {
  CylinderMesh({
    required double radius,
    required double height,
    int segments = 16,
    Material? material,
  }) {
    final vertices = <Vertex>[];
    final halfHeight = height / 2.0;

    // top circle
    for (var i = 0; i <= segments; i++) {
      final theta = i * tau / segments;
      final x = radius * math.cos(theta);
      final y = halfHeight;
      final z = radius * math.sin(theta);

      final u = (1 + math.cos(theta)) * 0.5;
      final v = (1 + math.sin(theta)) * 0.5;

      vertices.add(
        Vertex(position: Vector3(x, y, z), texCoord: Vector2(u, v)),
      );
    }

    // top center
    vertices.add(
      Vertex(position: Vector3(0, halfHeight, 0), texCoord: Vector2(0.5, 0.5)),
    );

    // bottom circle
    for (var i = 0; i <= segments; i++) {
      final theta = i * tau / segments;
      final x = radius * math.cos(theta);
      final y = -halfHeight;
      final z = radius * math.sin(theta);

      final u = (1 + math.cos(theta)) * 0.5;
      final v = (1 + math.sin(theta)) * 0.5;

      vertices.add(
        Vertex(position: Vector3(x, y, z), texCoord: Vector2(u, v)),
      );
    }

    // bottom center
    vertices.add(
      Vertex(position: Vector3(0, -halfHeight, 0), texCoord: Vector2(0.5, 0.5)),
    );

    final indices = <int>[];

    // top circle indices
    for (var i = 0; i < segments; i++) {
      indices.add(i);
      indices.add(i + 1);
      indices.add(segments + 1); // center index
    }

    // bottom circle indices
    for (var i = 0; i < segments; i++) {
      indices.add(segments + 1 + i);
      indices.add(segments + 1 + i + 1);
      indices.add(segments * 2 + 2); // center index
    }

    // side indices
    for (var i = 0; i < segments; i++) {
      final topIndex = i;
      final bottomIndex = i + segments + 1;
      indices.add(topIndex);
      indices.add(bottomIndex);
      indices.add(topIndex + 1);

      indices.add(bottomIndex);
      indices.add(bottomIndex + 1);
      indices.add(topIndex + 1);
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
