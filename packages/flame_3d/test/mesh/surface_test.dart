import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Surface', () {
    test('uploads every vertex followed by the indices', () {
      final backend = _RecordingBackend();
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
          weights: Vector4(.4, .3, .2, .1),
        ),
      ];
      final surface = Surface(vertices: vertices, indices: [0, 1, 2]);

      expect(surface.resource, same(backend.buffer));
      expect(surface.vertexCount, 3);
      expect(
        backend.buffer.writes.first.$2.buffer.asFloat32List(),
        orderedEquals([for (final vertex in vertices) ...vertex.storage]),
      );
      expect(backend.buffer.writes.last.$1, surface.verticesBytes);
      expect(
        backend.buffer.writes.last.$2.buffer.asUint16List(),
        orderedEquals([0, 1, 2]),
      );
    });
  });
}

final class _RecordingBackend() extends GpuBackend {
  final buffer = _RecordingBuffer();

  @override
  GpuBuffer createBuffer({
    required GpuStorageMode storageMode,
    required int sizeInBytes,
  }) => buffer;

  @override
  GpuTexture createTexture({
    required GpuStorageMode storageMode,
    required int width,
    required int height,
    required GpuPixelFormat format,
  }) => throw UnimplementedError();

  @override
  GpuShaderLibrary loadShaderLibrary(String assetName) {
    throw UnimplementedError();
  }

  @override
  GpuPipeline createPipeline({
    required GpuShader vertexShader,
    required GpuShader fragmentShader,
  }) => throw UnimplementedError();

  @override
  GpuRenderTarget createRenderTarget({
    required int width,
    required int height,
    required Color clearValue,
    int msaaSampleCount = 1,
  }) => throw UnimplementedError();

  @override
  GpuFrame beginFrame() => throw UnimplementedError();
}

class _RecordingBuffer() implements GpuBuffer {
  final List<(int, ByteData)> writes = [];

  @override
  void write(ByteData data, {int destinationOffsetInBytes = 0}) {
    writes.add((destinationOffsetInBytes, data));
  }
}
