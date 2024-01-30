import 'dart:math';

import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

class SphereGeometry extends Geometry {
  SphereGeometry({required double radius, required int segments}) {
    final vertices = <Vertex>[];
    final indices = <int>[];

    for (var i = 0; i <= segments; i++) {
      final theta = i * (2 * pi) / segments;
      for (var j = 0; j <= segments; j++) {
        final phi = j * pi / segments;

        final x = radius * sin(phi) * cos(theta);
        final y = radius * cos(phi);
        final z = radius * sin(phi) * sin(theta);

        final u = theta / (2 * pi);
        final v = phi / pi;

        vertices
            .add(Vertex(position: Vector3(x, y, z), texCoords: Vector2(u, v)));
      }
    }
    setVertices(vertices);

    for (var i = 0; i < segments; i++) {
      for (var j = 0; j < segments; j++) {
        final first = (i * (segments + 1)) + j;
        final second = first + segments + 1;

        indices.add(first);
        indices.add(second);
        indices.add(first + 1);

        indices.add(second);
        indices.add(second + 1);
        indices.add(first + 1);
      }
    }
    setIndices(indices);
  }
}
