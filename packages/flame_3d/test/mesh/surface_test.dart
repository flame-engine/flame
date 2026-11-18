import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_fakes/fake_gpu_backend.dart';

void main() {
  group('Surface', () {
    late FakeGpuBackend backend;

    setUp(() => backend = FakeGpuBackend());

    test('uploads every vertex followed by the indices', () {
      final vertices = [
        Vertex(
          position: Vector3(0, 0, 0),
          texCoord: Vector2(0, 0),
          normal: Vector3(0, 0, 1),
        ),
        Vertex(
          position: Vector3(1, 0, 0),
          texCoord: Vector2(1, 0),
          normal: Vector3(0, 0, 1),
          color: const Color(0xFFFF8000),
        ),
        Vertex(
          position: Vector3(0, 1, 0),
          texCoord: Vector2(0, 1),
          normal: Vector3(0, 0, 1),
          joints: Vector4(1, 2, 3, 4),
          weights: Vector4(0.4, 0.3, 0.2, 0.1),
        ),
      ];
      final surface = Surface(vertices: vertices, indices: [0, 1, 2]);

      final buffer = surface.resource as FakeBuffer;
      expect(buffer, same(backend.buffers.single));
      expect(surface.vertexCount, 3);
      expect(surface.layout, VertexLayout.standard);
      expect(
        buffer.writes.first.$2.buffer.asFloat32List(),
        orderedEquals([for (final vertex in vertices) ...vertex.storage]),
      );
      expect(buffer.writes.last.$1, surface.verticesBytes);
      expect(surface.indexType, GpuIndexType.uint16);
      expect(
        buffer.writes.last.$2.buffer.asUint16List(),
        orderedEquals([0, 1, 2]),
      );
    });

    test('uses 32-bit indices above 65,535 vertices', () {
      final vertices = List.generate(
        65536,
        (i) => Vertex(
          position: Vector3(i.toDouble(), 0, 0),
          texCoord: Vector2.zero(),
          normal: Vector3(0, 0, 1),
        ),
      );
      final surface = Surface(
        vertices: vertices,
        indices: [0, 65534, 65535],
      );

      expect(surface.indexType, GpuIndexType.uint32);
      expect(surface.indices, isA<Uint32List>());
      expect(surface.indices, orderedEquals([0, 65534, 65535]));
      expect(surface.indicesBytes, 12);
      final buffer = surface.resource as FakeBuffer;
      expect(
        buffer.contents.buffer.asUint32List(surface.indicesOffsetInBytes, 3),
        orderedEquals([0, 65534, 65535]),
      );
    });

    test('keeps 16-bit indices up to 65,535 vertices', () {
      final surface = Surface.fromBuffers(
        vertices: Float32List(65535 * VertexLayout.standard.strideInFloats),
        indices: Uint16List.fromList([0, 1, 65534]),
      );

      expect(surface.vertexCount, 65535);
      expect(surface.indexType, GpuIndexType.uint16);
    });

    test('can be built from typed arrays with a custom layout', () {
      final layout = VertexLayout(const [
        VertexAttribute('vertexPosition', 3),
        VertexAttribute('vertexColor', 4),
      ]);
      final vertices = Float32List.fromList([
        // position, color
        -1, 2, 0, 1, 0, 0, 1, //
        3, -4, 5, 0, 1, 0, 1, //
        0, 0, -6, 0, 0, 1, 1, //
      ]);
      final indices = Uint32List.fromList([0, 1, 2]);
      final surface = Surface.fromBuffers(
        vertices: vertices,
        indices: indices,
        layout: layout,
      );

      expect(surface.layout, same(layout));
      expect(surface.vertexCount, 3);
      expect(surface.vertexData, same(vertices));
      expect(surface.indices, same(indices));
      expect(surface.indexType, GpuIndexType.uint32);
      expect(surface.aabb.min, Vector3(-1, -4, -6));
      expect(surface.aabb.max, Vector3(3, 2, 5));
      expect(surface.positions, orderedEquals([-1, 2, 0, 3, -4, 5, 0, 0, -6]));

      final buffer = surface.resource as FakeBuffer;
      expect(buffer.sizeInBytes, vertices.lengthInBytes + 12);
      expect(
        buffer.contents.buffer.asFloat32List(0, vertices.length),
        orderedEquals(vertices),
      );
    });

    test('rejects vertex data that does not hold whole vertices', () {
      expect(
        () => Surface.fromBuffers(
          vertices: Float32List(VertexLayout.standard.strideInFloats + 1),
          indices: Uint16List(3),
        ),
        throwsArgumentError,
      );
    });

    test('rejects indices that are not 16 or 32-bit typed lists', () {
      expect(
        () => Surface.fromBuffers(
          vertices: Float32List(VertexLayout.standard.strideInFloats),
          indices: [0, 0, 0],
        ),
        throwsArgumentError,
      );
    });

    test('uses the given bounds', () {
      final aabb = Aabb3.minMax(Vector3.all(-2), Vector3.all(2));
      final surface = Surface.fromBuffers(
        vertices: Float32List(VertexLayout.standard.strideInFloats * 3),
        indices: Uint16List.fromList([0, 1, 2]),
        aabb: aabb,
      );

      expect(surface.aabb, same(aabb));
    });

    test('pads the index data of its buffer to 4 bytes', () {
      final surface = Surface.fromBuffers(
        vertices: Float32List(VertexLayout.standard.strideInFloats * 3),
        indices: Uint16List.fromList([0, 1, 2]),
      );

      expect((surface.resource as FakeBuffer).sizeInBytes % 4, 0);
    });
  });
}
