import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Material uniform keys', () {
    late _FakeBackend backend;
    late _RecordingDevice device;
    late RenderContext3D context;

    setUp(() {
      backend = _FakeBackend();
      device = _RecordingDevice(backend: backend);
      context = RenderContext3D(device);
    });

    void draw(Material material) {
      expect(material.vertexShader.resource, isNotNull);
      expect(material.fragmentShader.resource, isNotNull);
      material
        ..apply(context)
        ..vertexShader.bind(device)
        ..fragmentShader.bind(device);
    }

    for (final (name, create) in [
      ('UnlitMaterial', UnlitMaterial.new),
      ('SpatialMaterial', SpatialMaterial.new),
    ]) {
      test('$name writes each joint matrix at its index', () {
        final joints = [
          for (var i = 0; i < 16; i++)
            Matrix4.translationValues(i.toDouble(), i * 2, i * 3),
        ];
        context.jointsInfo.jointTransforms = joints;

        draw(create());

        final data = device.uniforms['JointMatrices']!;
        final base = backend.offsetOf('JointMatrices', 'joints');
        for (final (i, joint) in joints.indexed) {
          expect(
            data.sublist(base + i * 16, base + (i + 1) * 16),
            orderedEquals(joint.storage),
          );
        }
      });
    }

    test('SpatialMaterial writes each point light at its index', () {
      final lights = [
        for (var i = 0; i < 3; i++)
          Light(
            position: Vector3(i.toDouble(), i + 10, i + 20),
            source: PointLight(
              color: Color.fromARGB(255, i * 80, 255 - i * 80, 0),
              intensity: i + .5,
            ),
          ),
      ];
      context.lights = lights;

      draw(SpatialMaterial());

      final data = device.uniforms['Lights']!;
      final positions = backend.offsetOf('Lights', 'positions');
      final colors = backend.offsetOf('Lights', 'colors');
      final intensities = backend.offsetOf('Lights', 'intensities');
      expect(data[backend.offsetOf('Lights', 'numLights')], 3);
      for (final (i, light) in lights.indexed) {
        final color = light.source.color;
        expect(
          data.sublist(positions + i * 4, positions + i * 4 + 3),
          orderedEquals(Float32List.fromList(light.position.storage)),
        );
        expect(
          data.sublist(colors + i * 4, colors + i * 4 + 4),
          orderedEquals(
            Float32List.fromList([color.r, color.g, color.b, color.a]),
          ),
        );
        expect(
          data[intensities + i * 4],
          Float32List.fromList([light.source.intensity]).single,
        );
      }
    });
  });
}

final class _FakeBackend() extends GpuBackend {
  final Map<String, _FakeUniformSlot> slots = {};

  int offsetOf(String slot, String member) {
    return slots[slot]!.getMemberOffsetInBytes(member) ~/
        Float32List.bytesPerElement;
  }

  @override
  GpuShaderLibrary loadShaderLibrary(String assetName) {
    return _FakeShaderLibrary(this);
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

class _FakeShaderLibrary(final _FakeBackend backend)
    implements GpuShaderLibrary {
  @override
  GpuShader operator [](String entryPoint) => _FakeShader(backend);
}

class _FakeShader(final _FakeBackend backend) implements GpuShader {
  @override
  GpuUniformSlot getUniformSlot(String name) {
    if (name.endsWith('Texture')) {
      return _FakeSamplerSlot();
    }
    return backend.slots.putIfAbsent(name, () => _FakeUniformSlot(name));
  }
}

class _FakeSamplerSlot() implements GpuUniformSlot {
  @override
  int? get sizeInBytes => null;

  @override
  int? getMemberOffsetInBytes(String member) => null;
}

class _FakeUniformSlot(final String name) implements GpuUniformSlot {
  final Map<String, int> _offsets = {};

  @override
  int get sizeInBytes => 8192;

  @override
  int getMemberOffsetInBytes(String member) {
    return _offsets.putIfAbsent(member, () => _offsets.length * 1024);
  }
}

class _RecordingDevice({super.backend}) extends GraphicsDevice {
  final Map<String, Float32List> uniforms = {};

  @override
  void bindUniform(GpuUniformSlot slot, ByteBuffer buffer) {
    uniforms[(slot as _FakeUniformSlot).name] = Float32List.fromList(
      buffer.asFloat32List(),
    );
  }

  @override
  void bindTexture(GpuUniformSlot slot, Texture texture) {}
}
