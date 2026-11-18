import 'package:flame_3d/core.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_fakes/fake_gpu_backend.dart';

Surface _triangle(Vector3 a, Vector3 b, Vector3 c) {
  return Surface(
    vertices: [
      for (final p in [a, b, c]) Vertex(position: p, texCoord: Vector2.zero()),
    ],
    indices: [0, 1, 2],
  );
}

void main() {
  setUp(FakeGpuBackend.new);

  group('Mesh', () {
    test('bounds every surface without changing their own bounds', () {
      final first = _triangle(
        Vector3.zero(),
        Vector3(1, 0, 0),
        Vector3(0, 1, 0),
      );
      final second = _triangle(
        Vector3(5, 5, 5),
        Vector3(6, 5, 5),
        Vector3(5, 6, 5),
      );
      final mesh = Mesh()
        ..addSurface(first)
        ..addSurface(second);

      expect(mesh.aabb.min, Vector3.zero());
      expect(mesh.aabb.max, Vector3(6, 6, 5));
      expect(first.aabb.max, Vector3(1, 1, 0));
      expect(second.aabb.min, Vector3(5, 5, 5));
    });
  });

  group('built-in meshes', () {
    // Front faces are counter-clockwise: the normal given by the winding
    // must point out of the (convex) mesh, and agree with the vertex normals.
    final meshes = {
      'CuboidMesh': () => CuboidMesh(size: Vector3(1, 2, 3)),
      'PlaneMesh': () => PlaneMesh(size: Vector2(2, 3)),
      'SphereMesh': () => SphereMesh(radius: 1, segments: 12),
      'CylinderMesh': () => CylinderMesh(radius: 1, height: 2),
      'ConeMesh': () => ConeMesh(
        radius: 1,
        height: 2,
        segments: 12,
        material: Material.defaultMaterial,
      ),
    };

    for (final MapEntry(key: name, value: create) in meshes.entries) {
      test('$name has outward, counter-clockwise front faces', () {
        final mesh = create();
        final center = (mesh.aabb.min + mesh.aabb.max) / 2;
        for (final surface in mesh.surfaces) {
          final stride = surface.layout.strideInFloats;
          final data = surface.vertexData;
          Vector3 position(int i) => Vector3(
            data[i * stride],
            data[i * stride + 1],
            data[i * stride + 2],
          );
          Vector3 normal(int i) => Vector3(
            data[i * stride + 9],
            data[i * stride + 10],
            data[i * stride + 11],
          );
          for (var t = 0; t < surface.indexCount; t += 3) {
            final a = surface.indices[t];
            final b = surface.indices[t + 1];
            final c = surface.indices[t + 2];
            final face = (position(b) - position(a)).cross(
              position(c) - position(a),
            );
            if (face.length < 1e-9) {
              continue;
            }
            final centroid = (position(a) + position(b) + position(c)) / 3;
            final outward = name == 'PlaneMesh'
                ? Vector3(0, 1, 0)
                : centroid - center;
            expect(
              face.dot(outward),
              greaterThan(0),
              reason: 'triangle ${t ~/ 3} faces inwards',
            );
            for (final vertex in [a, b, c]) {
              expect(
                normal(vertex).dot(face),
                greaterThan(0),
                reason: 'vertex $vertex has an inward normal',
              );
            }
          }
        }
      });
    }

    test('CylinderMesh caps and side span the whole cylinder', () {
      final mesh = CylinderMesh(radius: 2, height: 4, segments: 8);
      final surface = mesh.surfaces.single;

      expect(mesh.aabb.min.y, -2);
      expect(mesh.aabb.max.y, 2);
      // 8 side quads and two 8-triangle caps.
      expect(surface.indexCount, (8 * 2 + 8 * 2) * 3);
    });
  });
}
