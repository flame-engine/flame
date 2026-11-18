import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_fakes/fake_gpu_backend.dart';

void main() {
  group('Material uniform keys', () {
    late FakeGpuBackend backend;
    late GraphicsDevice device;
    late RenderContext3D context;

    setUp(() {
      // Joint matrix blocks hold 64 matrices, like the built-in shaders.
      backend = FakeGpuBackend(blockSizes: {'JointMatrices': 4096});
      device = GraphicsDevice(backend: backend);
      context = RenderContext3D(device);
    });

    /// Draws a triangle with [material] in a pass and returns the data bound
    /// to each uniform block, by block name.
    Map<String, Float32List> draw(
      Material material, {
      List<Matrix4>? joints,
    }) {
      final surface = Surface(
        vertices: [
          Vertex(position: Vector3.zero(), texCoord: Vector2.zero()),
          Vertex(position: Vector3(1, 0, 0), texCoord: Vector2.zero()),
          Vertex(position: Vector3(0, 1, 0), texCoord: Vector2.zero()),
        ],
        indices: [0, 1, 2],
        material: material,
      );
      device.begin();
      context.setCamera(Matrix4.identity(), Matrix4.identity());
      device.beginPass(const Size(8, 8));
      context
        ..drawSurface(surface, jointTransforms: joints)
        ..flush();
      device
        ..endPass()
        ..end();
      return backend.uniforms;
    }

    int offsetOf(Material material, String block, String member) {
      final shader = block == RenderContext3D.jointMatricesBlock
          ? material.vertexShader
          : material.fragmentShader;
      return shader.slot(block).getMemberOffsetInBytes(member)! ~/
          Float32List.bytesPerElement;
    }

    for (final (name, create) in [
      ('UnlitMaterial', UnlitMaterial.new),
      ('SpatialMaterial', SpatialMaterial.new),
    ]) {
      test('$name gets each joint matrix at its index', () {
        final joints = [
          for (var i = 0; i < 16; i++)
            Matrix4.translationValues(i.toDouble(), i * 2, i * 3),
        ];
        final material = create();

        final data = draw(material, joints: joints)['JointMatrices']!;

        final base = offsetOf(material, 'JointMatrices', 'joints');
        for (final (i, joint) in joints.indexed) {
          expect(
            data.sublist(base + i * 16, base + (i + 1) * 16),
            orderedEquals(joint.storage),
          );
        }
      });

      test('$name rejects more joints than the shader holds', () {
        final joints = [for (var i = 0; i < 65; i++) Matrix4.identity()];
        expect(
          () => draw(create(), joints: joints),
          throwsA(isA<StateError>()),
        );
      });
    }

    test('SpatialMaterial gets each point light at its index', () {
      final lights = [
        for (var i = 0; i < 3; i++)
          Light(
            position: Vector3(i.toDouble(), i + 10, i + 20),
            source: PointLight(
              color: Color.fromARGB(255, i * 80, 255 - i * 80, 0),
              intensity: i + 0.5,
            ),
          ),
        Light(
          position: Vector3.zero(),
          source: AmbientLight(color: const Color(0xFF102030), intensity: 0.7),
        ),
      ];
      context.lights = lights;
      final material = SpatialMaterial();

      final uniforms = draw(material);
      final data = uniforms['Lights']!;
      final positions = offsetOf(material, 'Lights', 'positions');
      final colors = offsetOf(material, 'Lights', 'colors');
      final intensities = offsetOf(material, 'Lights', 'intensities');
      expect(data[offsetOf(material, 'Lights', 'numLights')], 3);
      for (final (i, light) in lights.take(3).indexed) {
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

      final ambient = uniforms['AmbientLight']!;
      final ambientColor = offsetOf(material, 'AmbientLight', 'color');
      expect(
        ambient.sublist(ambientColor, ambientColor + 4),
        orderedEquals(Float32List.fromList([16 / 255, 32 / 255, 48 / 255, 1])),
      );
      expect(
        ambient[offsetOf(material, 'AmbientLight', 'intensity')],
        Float32List.fromList([0.7]).single,
      );
    });

    test('SpatialMaterial gets at most eight point lights', () {
      context.lights = [
        for (var i = 0; i < 12; i++)
          Light(
            position: Vector3.all(i.toDouble()),
            source: PointLight(color: const Color(0xFFFFFFFF), intensity: 1),
          ),
      ];
      final material = SpatialMaterial();

      final data = draw(material)['Lights']!;

      expect(
        data[offsetOf(material, 'Lights', 'numLights')],
        RenderContext3D.maxPointLights,
      );
    });
  });
}
