import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_fakes/fake_gpu_backend.dart';

void main() {
  group('light uniforms', () {
    late FakeGpuBackend backend;
    late GraphicsDevice device;
    late RenderContext3D context;
    late SpatialMaterial material;

    setUp(() {
      backend = FakeGpuBackend(blockSizes: {'JointMatrices': 1024});
      device = GraphicsDevice(backend: backend);
      context = RenderContext3D(device);
      material = SpatialMaterial();
    });

    /// Draws a triangle with [material] lit by [lights] and returns the data
    /// bound to each uniform block, by block name.
    Map<String, Float32List> draw(List<Light> lights) {
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
      context
        ..lights = lights
        ..setCamera(Matrix4.identity(), Matrix4.identity());
      device.beginPass(const Size(8, 8));
      context
        ..drawSurface(surface)
        ..flush();
      device
        ..endPass()
        ..end();
      return backend.uniforms;
    }

    int offsetOf(String block, String member) {
      return material.fragmentShader
              .slot(block)
              .getMemberOffsetInBytes(member)! ~/
          Float32List.bytesPerElement;
    }

    List<double> read(Float32List data, String block, String member, int n) {
      final offset = offsetOf(block, member);
      return data.sublist(offset, offset + n);
    }

    Matcher closeToList(List<double> expected) {
      return pairwiseCompare<double, double>(
        expected,
        (a, b) => (a - b).abs() < 1e-6,
        'close to',
      );
    }

    test('directional lights get their direction, color and intensity', () {
      final rotated = Matrix4.rotationX(-math.pi / 2);
      final uniforms = draw([
        Light(
          position: Vector3.zero(),
          source: DirectionalLight(
            color: const Color(0xFFFF8000),
            intensity: 0.75,
            direction: Vector3(0, -2, 0),
            specular: 0.5,
          ),
        ),
        // No explicit direction: the light travels along the -Z axis of its
        // transform.
        Light(
          position: Vector3.zero(),
          source: DirectionalLight(intensity: 2),
          transform: rotated,
        ),
      ]);
      final data = uniforms[RenderContext3D.directionalLightsBlock]!;

      expect(data[offsetOf('DirectionalLights', 'numLights')], 2);
      final directions = offsetOf('DirectionalLights', 'directions');
      final colors = offsetOf('DirectionalLights', 'colors');
      // Towards the light: up.
      expect(
        data.sublist(directions, directions + 4),
        closeToList([0, 1, 0, 0.5]),
      );
      expect(
        data.sublist(colors, colors + 4),
        closeToList([1, 128 / 255, 0, 0.75]),
      );
      // -Z rotated by -90 degrees around X points down, so towards the light
      // is up.
      expect(
        data.sublist(directions + 4, directions + 8),
        closeToList([0, 1, 0, 1]),
      );
      expect(data.sublist(colors + 4, colors + 8), closeToList([1, 1, 1, 2]));
    });

    test('at most four directional lights are used', () {
      final data = draw([
        for (var i = 0; i < 6; i++)
          Light(
            position: Vector3.zero(),
            source: DirectionalLight(direction: Vector3(0, -1, 0)),
          ),
      ])[RenderContext3D.directionalLightsBlock]!;

      expect(
        data[offsetOf('DirectionalLights', 'numLights')],
        RenderContext3D.maxDirectionalLights,
      );
    });

    test('the hemisphere light gets its colors, up axis and intensity', () {
      final uniforms = draw([
        Light(
          position: Vector3.zero(),
          source: HemisphereLight(
            skyColor: const Color(0xFF3366FF),
            groundColor: const Color(0xFF804020),
            intensity: 0.44,
            up: Vector3(0, 0, 3),
          ),
        ),
      ]);
      final data = uniforms[RenderContext3D.hemisphereLightBlock]!;

      expect(
        read(data, 'HemisphereLight', 'skyColor', 4),
        closeToList([0.2, 0.4, 1, 1]),
      );
      expect(
        read(data, 'HemisphereLight', 'groundColor', 4),
        closeToList([128 / 255, 64 / 255, 32 / 255, 1]),
      );
      expect(read(data, 'HemisphereLight', 'up', 3), closeToList([0, 0, 1]));
      expect(
        read(data, 'HemisphereLight', 'intensity', 1),
        closeToList([0.44]),
      );
    });

    test('a scene without hemisphere light writes it dark', () {
      final data = draw(const [])[RenderContext3D.hemisphereLightBlock]!;

      expect(read(data, 'HemisphereLight', 'intensity', 1), [0]);
      expect(read(data, 'HemisphereLight', 'up', 3), [0, 1, 0]);
    });

    test('point lights get their range, or zero without one', () {
      final data = draw([
        Light(
          position: Vector3(1, 2, 3),
          source: PointLight(
            color: const Color(0xFFFFFFFF),
            intensity: 3,
            range: 4.5,
          ),
        ),
        Light(
          position: Vector3.zero(),
          source: PointLight(color: const Color(0xFFFFFFFF), intensity: 1),
        ),
        Light(
          position: Vector3.zero(),
          source: PointLight(
            color: const Color(0xFFFFFFFF),
            intensity: 1,
            range: -1,
          ),
        ),
      ])[RenderContext3D.lightsBlock]!;

      final ranges = offsetOf('Lights', 'ranges');
      expect(data[ranges], 4.5);
      expect(data[ranges + 4], 0);
      expect(data[ranges + 8], 0);
      expect(data[offsetOf('Lights', 'numLights')], 3);
    });

    test('point lights of zero intensity are left out', () {
      Light point(double x, double intensity) => Light(
        position: Vector3(x, 0, 0),
        source: PointLight(
          color: const Color(0xFFFFFFFF),
          intensity: intensity,
        ),
      );
      final data = draw([
        point(1, 0),
        point(2, 2),
        point(3, 0),
        point(4, 0.5),
      ])[RenderContext3D.lightsBlock]!;

      expect(data[offsetOf('Lights', 'numLights')], 2);
      final positions = offsetOf('Lights', 'positions');
      expect(data[positions], 2);
      expect(data[positions + 4], 4);
      final intensities = offsetOf('Lights', 'intensities');
      expect(data[intensities], 2);
      expect(data[intensities + 4], 0.5);
    });

    test('point lights of zero intensity count among the first eight', () {
      final data = draw([
        for (var i = 0; i < RenderContext3D.maxPointLights; i++)
          Light(
            position: Vector3(i.toDouble(), 0, 0),
            source: PointLight(
              color: const Color(0xFFFFFFFF),
              intensity: i.isEven ? 1 : 0,
            ),
          ),
        // A ninth point light, as before, is not written.
        Light(
          position: Vector3(9, 0, 0),
          source: PointLight(color: const Color(0xFFFFFFFF), intensity: 1),
        ),
      ])[RenderContext3D.lightsBlock]!;

      expect(
        data[offsetOf('Lights', 'numLights')],
        RenderContext3D.maxPointLights ~/ 2,
      );
      final positions = offsetOf('Lights', 'positions');
      expect(
        [for (var i = 0; i < 4; i++) data[positions + i * 4]],
        [0, 2, 4, 6],
      );
    });

    group('ambient light', () {
      test('defaults to white 0.2 without any ambient light', () {
        final data = draw(const [])[RenderContext3D.ambientLightBlock]!;

        expect(read(data, 'AmbientLight', 'color', 4), [1, 1, 1, 1]);
        expect(
          read(data, 'AmbientLight', 'intensity', 1),
          closeToList([0.2]),
        );
      });

      test('is dark when a hemisphere light replaces the default', () {
        final data = draw([
          Light(position: Vector3.zero(), source: HemisphereLight()),
        ])[RenderContext3D.ambientLightBlock]!;

        expect(read(data, 'AmbientLight', 'intensity', 1), [0]);
      });

      test('adds to a hemisphere light when the scene has one', () {
        final data = draw([
          Light(position: Vector3.zero(), source: HemisphereLight()),
          Light(
            position: Vector3.zero(),
            source: AmbientLight(intensity: 0.3),
          ),
        ])[RenderContext3D.ambientLightBlock]!;

        expect(
          read(data, 'AmbientLight', 'intensity', 1),
          closeToList([0.3]),
        );
      });
    });

    test('changed light values are written in the next pass', () {
      final sun = DirectionalLight(direction: Vector3(0, -1, 0));
      final lights = [Light(position: Vector3.zero(), source: sun)];
      draw(lights);

      sun
        ..intensity = 0.25
        ..direction!.setValues(1, 0, 0);
      final data = draw(lights)[RenderContext3D.directionalLightsBlock]!;

      final directions = offsetOf('DirectionalLights', 'directions');
      final colors = offsetOf('DirectionalLights', 'colors');
      expect(
        data.sublist(directions, directions + 3),
        closeToList([-1, 0, 0]),
      );
      expect(data[colors + 3], 0.25);
    });
  });
}
