import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Shader', () {
    test('can create vertex shader with slots', () {
      final shader = VertexShader.fromAsset(
        'none',
        slots: ['VertexInfo', 'JointMatrices'],
      );

      expect(shader.entryPoint, 'TextureVertex');
      expect(shader.slots, ['VertexInfo', 'JointMatrices']);
    });

    test('can create fragment shader with slots', () {
      final shader = FragmentShader.fromAsset(
        'none',
        slots: ['Material', 'Camera', 'albedoTexture'],
      );

      expect(shader.entryPoint, 'TextureFragment');
      expect(shader.slots, ['Material', 'Camera', 'albedoTexture']);
    });

    test('parses keys correctly', () {
      expect(Shader.parseKey('Foo.bar'), ('Foo', 'bar', null));

      expect(Shader.parseKey('Foo.bar[2]'), ('Foo', 'bar', 2));

      expect(Shader.parseKey('Foo'), ('Foo', null, null));
    });

    group('setColor', () {
      late _RecordingDevice device;
      late FragmentShader shader;

      setUp(() {
        device = _RecordingDevice(
          backend: _FakeBackend([
            _FakeUniformSlot('Material', 16, {'albedoColor': 0}),
            _FakeUniformSlot('Lights', 32, {'colors': 0}),
          ]),
        );
        shader = FragmentShader.fromAsset(
          'test',
          slots: ['Material', 'Lights'],
        );
        expect(shader.resource, isNotNull);
      });

      test('writes every distinct color it is given', () {
        for (var step = 0; step <= 255; step += 15) {
          final color = Color.fromARGB(255, step, 255 - step, step ~/ 2);
          shader
            ..setColor('Material.albedoColor', color)
            ..bind(device);

          expect(device.uniforms['Material'], orderedEquals(_channels(color)));
        }
      });

      test('keeps each array element independent', () {
        const first = Color(0xFFFF0000);
        const second = Color(0x800000FF);
        shader
          ..setColor('Lights.colors[0]', first)
          ..setColor('Lights.colors[1]', second)
          ..bind(device);

        expect(
          device.uniforms['Lights'],
          orderedEquals([..._channels(first), ..._channels(second)]),
        );
      });
    });
  });
}

Float32List _channels(Color color) {
  return Float32List.fromList([color.r, color.g, color.b, color.a]);
}

final class _FakeBackend(final List<_FakeUniformSlot> slots)
    extends GpuBackend {
  @override
  GpuShaderLibrary loadShaderLibrary(String assetName) {
    return _FakeShaderLibrary(slots);
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

class _FakeShaderLibrary(final List<_FakeUniformSlot> slots)
    implements GpuShaderLibrary {
  @override
  GpuShader operator [](String entryPoint) => _FakeShader(slots);
}

class _FakeShader(final List<_FakeUniformSlot> slots) implements GpuShader {
  @override
  GpuUniformSlot getUniformSlot(String slot) {
    return slots.firstWhere((candidate) => candidate.name == slot);
  }
}

class _FakeUniformSlot(
  final String name,
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
    uniforms[(slot as _FakeUniformSlot).name] = Float32List.fromList(
      buffer.asFloat32List(),
    );
  }
}
