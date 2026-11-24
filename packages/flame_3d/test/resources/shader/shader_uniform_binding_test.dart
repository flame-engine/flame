import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Shader uniform binding', () {
    late _FakeBackend backend;
    late _RecordingDevice device;
    late FragmentShader shader;

    setUp(() {
      backend = _FakeBackend({'value': 4, 'items': 8});
      device = _RecordingDevice(backend: backend);
      shader = FragmentShader.fromAsset('test', slots: ['Block']);
      expect(shader.resource, isNotNull);
    });

    test('writes the latest value set for a key', () {
      shader
        ..setVector2('Block.value', Vector2(1, 2))
        ..setVector2('Block.value', Vector2(3, 4))
        ..bind(device);

      expect(device.uniforms['Block']!.sublist(1, 3), orderedEquals([3, 4]));
    });

    test('writes array elements at their std140 stride', () {
      shader
        ..setVector3('Block.items[0]', Vector3(1, 2, 3))
        ..setVector3('Block.items[2]', Vector3(4, 5, 6))
        ..bind(device);

      final data = device.uniforms['Block']!;
      expect(data.sublist(2, 5), orderedEquals([1, 2, 3]));
      expect(data.sublist(10, 13), orderedEquals([4, 5, 6]));
    });

    test('reports an unknown member every time it is set', () {
      for (var i = 0; i < 2; i++) {
        expect(
          () => shader.setFloat('Block.missing', 1),
          throwsA(isA<StateError>()),
        );
      }
    });

    test('resolves keys again when the resource is recreated', () {
      shader.setFloat('Block.value', 1);
      backend.offsets = {'value': 12};
      shader.recreateResource = true;
      expect(shader.resource, isNotNull);

      shader
        ..setFloat('Block.value', 2)
        ..bind(device);

      final data = device.uniforms['Block']!;
      expect(data[1], 0);
      expect(data[3], 2);
    });
  });
}

final class _FakeBackend(var Map<String, int> offsets) extends GpuBackend {
  @override
  GpuShaderLibrary loadShaderLibrary(String assetName) {
    return _FakeShaderLibrary(_FakeUniformSlot(64, Map.of(offsets)));
  }

  @override
  GpuTexture createTexture({
    required GpuStorageMode storageMode,
    required int width,
    required int height,
    required GpuPixelFormat format,
  }) => throw UnimplementedError();

  @override
  GpuBuffer createBuffer({
    required GpuStorageMode storageMode,
    required int sizeInBytes,
  }) => throw UnimplementedError();

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

class _FakeShaderLibrary(final _FakeUniformSlot slot)
    implements GpuShaderLibrary {
  @override
  GpuShader operator [](String entryPoint) => _FakeShader(slot);
}

class _FakeShader(final _FakeUniformSlot slot) implements GpuShader {
  @override
  GpuUniformSlot getUniformSlot(String name) => slot;
}

class _FakeUniformSlot(
  @override final int sizeInBytes,
  final Map<String, int> offsets,
) implements GpuUniformSlot {
  @override
  int? getMemberOffsetInBytes(String member) => offsets[member];
}

class _RecordingDevice({super.backend}) extends GraphicsDevice {
  final Map<String, Float32List> uniforms = {};

  @override
  void bindUniform(GpuUniformSlot slot, ByteBuffer buffer) {
    uniforms['Block'] = Float32List.fromList(buffer.asFloat32List());
  }
}
