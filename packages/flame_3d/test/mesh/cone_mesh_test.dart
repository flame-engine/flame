import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Cone Mesh', () {
    test('can create a simple cone', () {
      const segments = 17;

      final cone = ConeMesh(
        radius: 1.0,
        height: 1.0,
        segments: segments,
        material: SpatialMaterial(),
      );

      expect(
        cone.surfaces,
        hasLength(2),
      );

      expect(
        cone.surfaces.map((s) => s.vertexCount).toSet(),
        equals({segments + 1}),
      );

      expect(
        cone.surfaces.map((s) => s.indexCount).toSet(),
        equals({segments * 3}),
      );
    });
  });
}
