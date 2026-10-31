import 'dart:typed_data';
import 'dart:ui' hide FragmentShader;

import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpatialMaterial', () {
    test('binds every point light up to the shader limit', () {
      final lights = _bind(8);

      expect(lights[0], 8);
      expect(_color(lights, 0), [1, 0, 0, 1]);
      expect(_position(lights, 7), [7, 7, 7]);
    });

    test('ignores point lights beyond the shader limit', () {
      final lights = _bind(9);

      expect(lights[0], 8);
      expect(_color(lights, 0), [1, 0, 0, 1]);
      expect(_intensity(lights, 0), 1);
      expect(_position(lights, 7), [7, 7, 7]);
    });
  });
}

const _positions = 4;
const _colors = 36;
const _intensities = 68;

Float32List _bind(int pointLights) {
  final backend = _Backend();
  final device = _Device(backend: backend);
  final material = SpatialMaterial();
  material.vertexShader.resource;
  material.fragmentShader.resource;
  final context = RenderContext3D(device)
    ..lights = [
      for (var index = 0; index < pointLights; index++)
        Light(
          position: Vector3.all(index.toDouble()),
          source: PointLight(
            color: index == 0
                ? const Color(0xFFFF0000)
                : const Color(0xFF00FF00),
            intensity: index + 1,
          ),
        ),
    ];

  material.apply(context);
  material.fragmentShader.bind(device);

  return device.uniforms['Lights']!.asFloat32List();
}

List<double> _position(Float32List lights, int index) =>
    lights.sublist(_positions + index * 4, _positions + index * 4 + 3);

List<double> _color(Float32List lights, int index) =>
    lights.sublist(_colors + index * 4, _colors + index * 4 + 4);

double _intensity(Float32List lights, int index) =>
    lights[_intensities + index * 4];

final class _Backend() extends GpuBackend {
  @override
  GpuShaderLibrary loadShaderLibrary(String assetName) => _Library();

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName}');
}

class _Device({required super.backend}) extends GraphicsDevice {
  final uniforms = <String, ByteBuffer>{};

  @override
  void bindUniform(GpuUniformSlot slot, ByteBuffer buffer) =>
      uniforms[(slot as _Slot).name] = buffer;

  @override
  void bindTexture(GpuUniformSlot slot, Texture texture) {}
}

class _Library() implements GpuShaderLibrary {
  @override
  GpuShader operator [](String entryPoint) => _Shader();
}

class _Shader() implements GpuShader {
  @override
  GpuUniformSlot getUniformSlot(String slot) => _Slot(slot);
}

class _Slot(final String name) implements GpuUniformSlot {
  static const _layouts = <String, (int, Map<String, int>)>{
    'VertexInfo': (192, {'model': 0, 'view': 64, 'projection': 128}),
    'JointMatrices': (1024, {'joints': 0}),
    'Material': (32, {'albedoColor': 0, 'metallic': 16, 'roughness': 20}),
    'AmbientLight': (32, {'color': 0, 'intensity': 16}),
    'Lights': (
      400,
      {'numLights': 0, 'positions': 16, 'colors': 144, 'intensities': 272},
    ),
    'Camera': (16, {'position': 0}),
  };

  @override
  int? get sizeInBytes => _layouts[name]?.$1;

  @override
  int? getMemberOffsetInBytes(String member) => _layouts[name]?.$2[member];
}
