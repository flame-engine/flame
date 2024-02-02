import 'dart:math' as math;

import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

class SphereMesh extends Mesh {
  SphereMesh({
    required double radius,
    int segments = 64,
    Material? material,
  }) {
    final vertices = <Vertex>[];
    for (var i = 0; i <= segments; i++) {
      final theta = i * (2 * math.pi) / segments;
      for (var j = 0; j <= segments; j++) {
        final phi = j * math.pi / segments;

        final x = radius * math.sin(phi) * math.cos(theta);
        final y = radius * math.cos(phi);
        final z = radius * math.sin(phi) * math.sin(theta);

        final u = theta / (2 * math.pi);
        final v = phi / math.pi;

        vertices.add(
          Vertex(position: Vector3(x, y, z), texCoord: Vector2(u, v)),
        );
      }
    }

    final indices = <int>[];
    for (var i = 0; i < segments; i++) {
      for (var j = 0; j < segments; j++) {
        final first = i * (segments + 1) + j;
        final second = first + segments + 1;

        indices.add(first);
        indices.add(second);
        indices.add(first + 1);

        indices.add(second);
        indices.add(second + 1);
        indices.add(first + 1);
      }
    }

    addSurface(vertices, indices, material: material);
  }
}
