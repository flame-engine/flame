import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_fakes/fake_gpu_backend.dart';

void main() {
  group('StylizedMaterial', () {
    late FakeGpuBackend backend;
    late GraphicsDevice device;
    late RenderContext3D context;

    setUp(() {
      // The fake backend lays members out 1024 bytes apart.
      backend = FakeGpuBackend(
        blockSizes: {
          'JointMatrices': 4096,
          'Material': 36 * 1024,
          'Wind': 16 * 1024,
          RenderContext3D.stylizedPassBlock: 40 * 1024,
        },
      );
      device = GraphicsDevice(backend: backend);
      context = RenderContext3D(device);
    });

    void draw(List<Surface> surfaces) {
      device.begin();
      context.setCamera(Matrix4.identity(), Matrix4.identity());
      device.beginPass(const Size(8, 8));
      for (final surface in surfaces) {
        context.drawSurface(surface);
      }
      context.flush();
      device
        ..endPass()
        ..end();
    }

    Surface stylizedTriangle(Material material) {
      return StylizedMaterial.buildSurface(
        positions: [0, 0, 0, 1, 0, 0, 0, 1, 0],
        normals: [0, 0, 1, 0, 0, 1, 0, 0, 1],
        indices: [0, 1, 2],
        material: material,
      );
    }

    Surface skinnedTriangle(Material material) {
      return StylizedMaterial.buildSurface(
        positions: [0, 0, 0, 1, 0, 0, 0, 1, 0],
        normals: [0, 0, 1, 0, 0, 1, 0, 0, 1],
        joints: [0, 0, 0, 0, 1, 0, 0, 0, 1, 2, 0, 0],
        weights: [1, 0, 0, 0, 1, 0, 0, 0, 0.5, 0.5, 0, 0],
        indices: [0, 1, 2],
        material: material,
      );
    }

    Surface standardTriangle(Material material) {
      return Surface(
        vertices: [
          Vertex(position: Vector3.zero(), texCoord: Vector2.zero()),
          Vertex(position: Vector3(1, 0, 0), texCoord: Vector2.zero()),
          Vertex(position: Vector3(0, 1, 0), texCoord: Vector2.zero()),
        ],
        indices: [0, 1, 2],
        material: material,
      );
    }

    test('lays out 18 floats per vertex', () {
      final layout = StylizedMaterial.vertexLayout;

      expect(layout.strideInFloats, 18);
      expect(
        [for (final a in layout.attributes) (a.name, a.components)],
        [
          ('vertexPosition', 3),
          ('vertexNormal', 3),
          ('vertexColor', 4),
          ('vertexMasks', 4),
          ('vertexOcclusion', 1),
          ('vertexWind', 3),
        ],
      );
    });

    test('draws its layout and the standard one with a variant each', () {
      final material = StylizedMaterial();

      draw([stylizedTriangle(material), standardTriangle(material)]);

      expect(backend.pipelines, hasLength(2));
      final [first, second] = backend.pipelines;
      expect(identical(first.vertexShader, second.vertexShader), isFalse);
      expect(identical(first.fragmentShader, second.fragmentShader), isTrue);
      expect(
        material.vertexShaderFor(StylizedMaterial.vertexLayout),
        material.vertexShader,
      );
      expect(
        material.vertexShaderFor(VertexLayout.standard),
        isNot(material.vertexShader),
      );
    });

    test('lays out 26 floats per skinned vertex', () {
      final layout = StylizedMaterial.skinnedVertexLayout;

      expect(layout.strideInFloats, 26);
      expect(
        [for (final a in layout.attributes) (a.name, a.components)],
        [
          for (final a in StylizedMaterial.vertexLayout.attributes)
            (a.name, a.components),
          ('vertexJoints', 4),
          ('vertexWeights', 4),
        ],
      );
    });

    test('draws skinned surfaces with a variant of their own', () {
      final material = StylizedMaterial();

      draw([
        stylizedTriangle(material),
        skinnedTriangle(material),
        standardTriangle(material),
      ]);

      expect(backend.pipelines, hasLength(3));
      final shaders = {for (final p in backend.pipelines) p.vertexShader};
      expect(shaders, hasLength(3));
      expect(
        {for (final p in backend.pipelines) p.fragmentShader},
        hasLength(1),
      );
      final skinned = material.vertexShaderFor(
        StylizedMaterial.skinnedVertexLayout,
      );
      expect(skinned, isNot(material.vertexShader));
      expect(skinned, isNot(material.vertexShaderFor(VertexLayout.standard)));
      expect(skinned.slots, contains(RenderContext3D.jointMatricesBlock));
    });

    test('feeds a skinned draw its joint matrices and its wind', () {
      final material = StylizedMaterial(
        windTime: 1.5,
        windSpace: WindSpace.model,
        windDirection: Vector3(0, 1, 0),
      );
      final joints = [
        Matrix4.identity(),
        Matrix4.translationValues(1, 2, 3),
        Matrix4.diagonal3Values(2, 2, 2),
      ];

      device.begin();
      context.setCamera(Matrix4.identity(), Matrix4.identity());
      device.beginPass(const Size(8, 8));
      context.drawSurface(skinnedTriangle(material), jointTransforms: joints);
      context.flush();
      device
        ..endPass()
        ..end();

      final skinned = material.vertexShaderFor(
        StylizedMaterial.skinnedVertexLayout,
      );
      List<double> member(String block, String name, int n) {
        final offset = skinned.slot(block).getMemberOffsetInBytes(name)! ~/ 4;
        return backend.uniforms[block]!.sublist(offset, offset + n);
      }

      expect(member('Wind', 'time', 1), [1.5]);
      expect(member('Wind', 'modelDirection', 3), [0, 1, 0]);
      final matrices = member('JointMatrices', 'joints', 48);
      expect(matrices.sublist(16, 32), joints[1].storage);
      expect(matrices.sublist(32, 48), joints[2].storage);
    });

    test('writes its color grade, neutral by default', () {
      final neutral = StylizedMaterial();
      final graded = StylizedMaterial(
        saturation: 0.25,
        overlayColor: const Color(0x80FF0000),
      );

      List<double> member(StylizedMaterial material, String name, int n) {
        draw([stylizedTriangle(material)]);
        final offset =
            material.fragmentShader
                .slot('Material')
                .getMemberOffsetInBytes(name)! ~/
            4;
        return backend.uniforms['Material']!.sublist(offset, offset + n);
      }

      expect(member(neutral, 'saturation', 1), [1]);
      expect(member(neutral, 'overlayColor', 4), [0, 0, 0, 0]);
      expect(member(graded, 'saturation', 1), [0.25]);
      expect(
        member(graded, 'overlayColor', 4),
        pairwiseCompare<double, double>(
          [1, 0, 0, 128 / 255],
          (a, b) => (a - b).abs() < 1e-6,
          'close to',
        ),
      );
    });

    test('writes its values into its uniform blocks', () {
      final material = StylizedMaterial(
        accentColor: const Color(0xFF336699),
        skyFill: 0.4,
        specularPower: 16,
        windTime: 2.5,
        windDirection: Vector3(0, 0, 1),
      );

      draw([stylizedTriangle(material)]);

      double value(Shader shader, String block, String member) {
        final offset = shader.slot(block).getMemberOffsetInBytes(member)! ~/ 4;
        return backend.uniforms[block]![offset];
      }

      final fragment = material.fragmentShader;
      final vertex = material.vertexShader;
      expect(value(fragment, 'Material', 'skyFill'), closeTo(0.4, 1e-6));
      expect(value(fragment, 'Material', 'specularPower'), 16);
      expect(value(fragment, 'Material', 'groundBounce'), closeTo(0.1, 1e-6));
      // Without MatCap texture, it has no effect.
      expect(value(fragment, 'Material', 'matCapStrength'), 0);
      expect(value(vertex, 'Wind', 'time'), 2.5);
      expect(value(vertex, 'Wind', 'frequency'), closeTo(2.3, 1e-6));
      final direction =
          vertex.slot('Wind').getMemberOffsetInBytes('direction')! ~/ 4;
      expect(
        backend.uniforms['Wind']!.sublist(direction, direction + 3),
        [0, 0, 1],
      );
      final accent =
          fragment.slot('Material').getMemberOffsetInBytes('accentColor')! ~/ 4;
      expect(
        backend.uniforms['Material']!.sublist(accent, accent + 3),
        pairwiseCompare<double, double>(
          [0.2, 0.4, 0.6],
          (a, b) => (a - b).abs() < 1e-6,
          'close to',
        ),
      );
      expect(backend.textureBindings.keys, contains('matCapTexture'));
    });

    test('writes the defaults of its additions', () {
      final material = StylizedMaterial(
        emissiveColor: const Color(0xFF336699),
        skyFill: 0.5,
      );

      draw([stylizedTriangle(material)]);

      List<double> member(Shader shader, String block, String name, int n) {
        final offset = shader.slot(block).getMemberOffsetInBytes(name)! ~/ 4;
        return backend.uniforms[block]!.sublist(offset, offset + n);
      }

      final fragment = material.fragmentShader;
      final vertex = material.vertexShader;
      expect(material.renderState, RenderState.opaque);
      // The boost color is the emissive color, the sky fill is gray.
      expect(
        member(fragment, 'Material', 'emissiveBoostColor', 3),
        member(fragment, 'Material', 'emissiveColor', 3),
      );
      expect(member(fragment, 'Material', 'skyFill', 3), [0.5, 0.5, 0.5]);
      // Without MatCap textures no vertex gets one; with a texture the
      // first MatCap applies to every glossy vertex, in proportion to its
      // gloss (see below).
      expect(
        member(fragment, 'Material', 'matCapThreshold', 1).single,
        greaterThan(1e29),
      );
      expect(member(fragment, 'Material', 'matCapGlossWeight', 1), [1]);
      expect(member(fragment, 'Material', 'gemMatCapStrength', 1), [0]);
      expect(
        member(fragment, 'Material', 'gemThreshold', 1).single,
        greaterThan(1e29),
      );
      // The MatCap is an added sheen, not a metal's reflection.
      expect(member(fragment, 'Material', 'matCapMetallic', 1), [0]);
      // World-space wind.
      expect(member(vertex, 'Wind', 'direction', 3), [1, 0, 0]);
      expect(member(vertex, 'Wind', 'modelDirection', 3), [0, 0, 0]);
      expect(backend.textureBindings.keys, contains('gemMatCapTexture'));
    });

    test('writes its additions', () {
      final gem = ColorTexture(const Color(0xFF00FF00));
      final material = StylizedMaterial(
        skyFill: 0.5,
        skyFillWeight: Vector3(1, 0.5, 0.25),
        gemMatCapTexture: gem,
        gemMatCapStrength: 0.75,
        gemThreshold: 1.5,
        matCapMetallic: 0.75,
        windSpace: WindSpace.model,
        windDirection: Vector3(0, 1, 0),
        translucent: true,
      );

      draw([stylizedTriangle(material)]);

      List<double> member(Shader shader, String block, String name, int n) {
        final offset = shader.slot(block).getMemberOffsetInBytes(name)! ~/ 4;
        return backend.uniforms[block]!.sublist(offset, offset + n);
      }

      final fragment = material.fragmentShader;
      final vertex = material.vertexShader;
      expect(material.renderState, StylizedMaterial.translucentRenderState);
      expect(member(fragment, 'Material', 'skyFill', 3), [0.5, 0.25, 0.125]);
      expect(member(fragment, 'Material', 'gemMatCapStrength', 1), [0.75]);
      expect(member(fragment, 'Material', 'gemThreshold', 1), [1.5]);
      expect(member(fragment, 'Material', 'matCapMetallic', 1), [0.75]);
      expect(member(vertex, 'Wind', 'direction', 3), [0, 0, 0]);
      expect(member(vertex, 'Wind', 'modelDirection', 3), [0, 1, 0]);
      expect(
        identical(
          backend.textureBindings['gemMatCapTexture']!.$1,
          gem.resource,
        ),
        isTrue,
      );
    });

    group('wind', () {
      List<double> windMember(StylizedMaterial material, String name, int n) {
        final offset =
            material.vertexShader.slot('Wind').getMemberOffsetInBytes(name)! ~/
            4;
        return backend.uniforms['Wind']!.sublist(offset, offset + n);
      }

      Matcher closeToAll(List<double> expected) {
        return pairwiseCompare<double, double>(
          expected,
          (a, b) => (a - b).abs() < 1e-6,
          'close to',
        );
      }

      test('turns the flutter, the gusts and the scaling off by default', () {
        final material = StylizedMaterial();

        draw([stylizedTriangle(material)]);

        expect(material.windSpace, WindSpace.world);
        expect(windMember(material, 'flutterAmplitude', 1), [0]);
        expect(windMember(material, 'gustAmplitude', 1), [0]);
        // Without an up axis, the world-space sway is not scaled.
        expect(windMember(material, 'upAxis', 3), [0, 0, 0]);
        expect(windMember(material, 'flutterFrequency', 1), [12]);
        expect(
          windMember(material, 'gustFrequency', 1),
          closeToAll([0.8]),
        );
        // Along +x, half a radian per unit.
        expect(windMember(material, 'gustWave', 3), [0.5, 0, 0]);
        expect(material.windUpAxis, Vector3(0, 1, 0));
        expect(material.windGustDirection, Vector3(1, 0, 0));
      });

      test('writes its flutter and its gusts', () {
        final material = StylizedMaterial(
          windFlutterAmplitude: 0.01,
          windFlutterFrequency: 9,
          windGustAmplitude: 0.4,
          windGustFrequency: 0.25,
          windGustDirection: Vector3(0, 3, 4),
          windGustPhaseScale: 2,
        );

        draw([stylizedTriangle(material)]);

        expect(windMember(material, 'flutterAmplitude', 1), closeToAll([0.01]));
        expect(windMember(material, 'flutterFrequency', 1), [9]);
        expect(windMember(material, 'gustAmplitude', 1), closeToAll([0.4]));
        expect(windMember(material, 'gustFrequency', 1), [0.25]);
        // The direction normalized, times the phase scale.
        expect(windMember(material, 'gustWave', 3), closeToAll([0, 1.2, 1.6]));

        // A gust direction of zero gusts every object in unison.
        material.windGustDirection.setZero();
        draw([stylizedTriangle(material)]);
        expect(windMember(material, 'gustWave', 3), [0, 0, 0]);
      });

      test('scales a world-space wind along the up axis in worldScaled', () {
        final material = StylizedMaterial(
          windSpace: WindSpace.worldScaled,
          windDirection: Vector3(1, 0, 0),
          windUpAxis: Vector3(0, 0, 2),
        );

        draw([stylizedTriangle(material)]);

        expect(windMember(material, 'direction', 3), [1, 0, 0]);
        expect(windMember(material, 'modelDirection', 3), [0, 0, 0]);
        // Normalized.
        expect(windMember(material, 'upAxis', 3), [0, 0, 1]);

        material.windSpace = WindSpace.model;
        draw([stylizedTriangle(material)]);
        expect(windMember(material, 'direction', 3), [0, 0, 0]);
        expect(windMember(material, 'modelDirection', 3), [1, 0, 0]);
        expect(windMember(material, 'upAxis', 3), [0, 0, 0]);
      });

      test('writes the same wind into the skinned variant', () {
        final material = StylizedMaterial(
          windSpace: WindSpace.worldScaled,
          windFlutterAmplitude: 0.02,
          windGustAmplitude: 0.3,
        );

        device.begin();
        context.setCamera(Matrix4.identity(), Matrix4.identity());
        device.beginPass(const Size(8, 8));
        context.drawSurface(
          skinnedTriangle(material),
          jointTransforms: [Matrix4.identity()],
        );
        context.flush();
        device
          ..endPass()
          ..end();

        final skinned = material.vertexShaderFor(
          StylizedMaterial.skinnedVertexLayout,
        );
        List<double> member(String name, int n) {
          final offset =
              skinned.slot('Wind').getMemberOffsetInBytes(name)! ~/ 4;
          return backend.uniforms['Wind']!.sublist(offset, offset + n);
        }

        expect(member('upAxis', 3), [0, 1, 0]);
        expect(member('flutterAmplitude', 1), closeToAll([0.02]));
        expect(member('gustAmplitude', 1), closeToAll([0.3]));
      });
    });

    group('pass block', () {
      test('binds 7 resources for a draw: the pass in one block', () {
        final material = StylizedMaterial();

        draw([stylizedTriangle(material)]);

        final commands = backend.commands;
        final bound = [
          for (final command in commands.take(
            commands.indexWhere((c) => c.startsWith('drawIndexed')),
          ))
            if (command.startsWith('bindUniform ') ||
                command.startsWith('bindTexture '))
              command.split(' ').last,
        ];
        expect(bound.toSet(), {
          RenderContext3D.cameraMatricesBlock,
          'Wind',
          'Material',
          RenderContext3D.stylizedPassBlock,
          'matCapTexture',
          'gemMatCapTexture',
          RenderContext3D.shadowMapSampler,
        });
        expect(bound, hasLength(7));
        for (final block in [
          RenderContext3D.cameraBlock,
          RenderContext3D.ambientLightBlock,
          RenderContext3D.lightsBlock,
          RenderContext3D.directionalLightsBlock,
          RenderContext3D.hemisphereLightBlock,
          RenderContext3D.shadowsBlock,
        ]) {
          expect(bound, isNot(contains(block)));
        }
      });

      List<double> passMember(StylizedMaterial material, String name, int n) {
        final offset =
            material.fragmentShader
                .slot(RenderContext3D.stylizedPassBlock)
                .getMemberOffsetInBytes(name)! ~/
            4;
        return backend.uniforms[RenderContext3D.stylizedPassBlock]!.sublist(
          offset,
          offset + n,
        );
      }

      test('holds the camera, the lights and the shadows of the pass', () {
        final material = StylizedMaterial();
        context.lights = [
          Light(
            position: Vector3.zero(),
            source: AmbientLight(intensity: 0.3),
          ),
          Light(
            position: Vector3.zero(),
            source: HemisphereLight(
              skyColor: const Color(0xFF0000FF),
              intensity: 0.4,
              up: Vector3(0, 0, 2),
            ),
          ),
          Light(
            position: Vector3.zero(),
            source: DirectionalLight(
              direction: Vector3(0, -1, 0),
              intensity: 0.7,
            ),
          ),
          Light(
            position: Vector3(1, 2, 3),
            source: PointLight(
              color: const Color(0xFFFFFFFF),
              intensity: 2,
              range: 5,
            ),
          ),
        ];

        device.begin();
        context.setCamera(
          Matrix4.translationValues(0, 0, -4),
          Matrix4.identity(),
        );
        device.beginPass(const Size(8, 8));
        context.drawSurface(stylizedTriangle(material));
        context.flush();
        device
          ..endPass()
          ..end();

        expect(passMember(material, 'AmbientLight_intensity', 1), [
          closeTo(0.3, 1e-6),
        ]);
        expect(passMember(material, 'HemisphereLight_up', 3), [0, 0, 1]);
        expect(passMember(material, 'HemisphereLight_skyColor', 4), [
          0,
          0,
          1,
          1,
        ]);
        expect(passMember(material, 'DirectionalLights_numLights', 1), [1]);
        // From a surface towards the light, and the specular factor.
        expect(passMember(material, 'DirectionalLights_directions', 4), [
          0,
          1,
          0,
          1,
        ]);
        expect(passMember(material, 'Lights_numLights', 1), [1]);
        expect(passMember(material, 'Lights_positions', 3), [1, 2, 3]);
        expect(passMember(material, 'Lights_ranges', 1), [5]);
        expect(passMember(material, 'Camera_position', 3), [0, 0, 4]);
        expect(
          passMember(material, 'Camera_view', 16),
          context.view.storage,
        );
        // No shadows in this pass.
        expect(passMember(material, 'Shadows_toLight', 4)[3], -1);
      });

      test('is written by the writers registered for its parts', () {
        final material = StylizedMaterial();
        context.registerPassUniform(
          RenderContext3D.lightsBlock,
          (context, block) => block.setFloat('numLights', 3),
        );

        draw([stylizedTriangle(material)]);

        expect(passMember(material, 'Lights_numLights', 1), [3]);
        expect(
          context.passUniforms.keys,
          isNot(contains(RenderContext3D.stylizedPassBlock)),
        );
      });
    });

    test('binds its MatCap texture with its strength', () {
      final matCap = ColorTexture(const Color(0xFFFF0000));
      final material = StylizedMaterial(
        matCapTexture: matCap,
        matCapStrength: 0.75,
      );

      draw([stylizedTriangle(material)]);

      int offsetOf(String member) =>
          material.fragmentShader
              .slot('Material')
              .getMemberOffsetInBytes(member)! ~/
          4;
      expect(backend.uniforms['Material']![offsetOf('matCapStrength')], 0.75);
      // Every glossy vertex gets it, in proportion to its gloss; no vertex
      // is a gem.
      expect(backend.uniforms['Material']![offsetOf('matCapThreshold')], 0);
      expect(
        backend.uniforms['Material']![offsetOf('gemThreshold')],
        greaterThan(1e29),
      );
      expect(
        identical(
          backend.textureBindings['matCapTexture']!.$1,
          matCap.resource,
        ),
        isTrue,
      );
    });

    group('buildSurface', () {
      test('packs the vertex arrays, with defaults', () {
        final surface = StylizedMaterial.buildSurface(
          positions: [1, 2, 3, 4, 5, 6],
          normals: [0, 1, 0, 0, 0, 1],
          colors: [0.1, 0.2, 0.3, 1, 0.5, 0.6, 0.7, 0.8],
          gloss: [0.5, 2],
          sway: [0, 1],
          indices: [0, 1, 0],
          material: StylizedMaterial(),
        );

        expect(surface.layout, StylizedMaterial.vertexLayout);
        expect(surface.vertexCount, 2);
        expect(
          surface.vertexData,
          Float32List.fromList([
            1, 2, 3, 0, 1, 0, 0.1, 0.2, 0.3, 1, 0, 0, 0, 0.5, 1, 0, 0, 0, //
            4, 5, 6, 0, 0, 1, 0.5, 0.6, 0.7, 0.8, 0, 0, 0, 2, 1, 1, 0, 0, //
          ]),
        );
        expect(surface.indices, isA<Uint16List>());
      });

      test('packs the wind of each vertex: sway, phase and flutter', () {
        final surface = StylizedMaterial.buildSurface(
          positions: [1, 2, 3, 4, 5, 6],
          normals: [0, 1, 0, 0, 0, 1],
          sway: [0.5, 1],
          windPhase: [0.25, 0.75],
          windFlutter: [1, 0.5],
          indices: [0, 1, 0],
          material: StylizedMaterial(),
        );

        final wind = StylizedMaterial.vertexLayout.offsetOf(
          StylizedMaterial.windAttribute,
        )!;
        expect(wind, 15);
        final data = surface.vertexData;
        expect(data.sublist(wind, wind + 3), [0.5, 0.25, 1]);
        expect(data.sublist(18 + wind, 18 + wind + 3), [1, 0.75, 0.5]);

        final skinned = StylizedMaterial.buildSurface(
          positions: [1, 2, 3],
          normals: [0, 1, 0],
          sway: [0.5],
          windPhase: [0.25],
          windFlutter: [1],
          joints: [1, 0, 0, 0],
          weights: [1, 0, 0, 0],
          indices: [0, 0, 0],
          material: StylizedMaterial(),
        );
        expect(
          StylizedMaterial.skinnedVertexLayout.offsetOf(
            StylizedMaterial.windAttribute,
          ),
          wind,
        );
        expect(skinned.vertexData.sublist(wind, wind + 3), [0.5, 0.25, 1]);
        expect(skinned.vertexData.sublist(18, 26), [1, 0, 0, 0, 1, 0, 0, 0]);
      });

      test('uses 32-bit indices when they do not fit in 16 bits', () {
        final surface = StylizedMaterial.buildSurface(
          positions: List.filled(70000 * 3, 0),
          normals: List.filled(70000 * 3, 0),
          indices: [0, 1, 69999],
          material: StylizedMaterial(),
        );

        expect(surface.indices, isA<Uint32List>());
      });

      test('packs joints and weights in the skinned layout', () {
        final surface = StylizedMaterial.buildSurface(
          positions: [1, 2, 3, 4, 5, 6],
          normals: [0, 1, 0, 0, 0, 1],
          joints: [0, 1, 0, 0, 15, 2, 3, 4],
          weights: [0.75, 0.25, 0, 0, 0.4, 0.3, 0.2, 0.1],
          indices: [0, 1, 0],
          material: StylizedMaterial(),
        );

        expect(surface.layout, StylizedMaterial.skinnedVertexLayout);
        expect(surface.vertexCount, 2);
        final data = surface.vertexData;
        expect(data.length, 52);
        expect(data.sublist(0, 6), [1, 2, 3, 0, 1, 0]);
        expect(data.sublist(18, 26), [0, 1, 0, 0, 0.75, 0.25, 0, 0]);
        expect(
          data.sublist(44, 52),
          pairwiseCompare<double, double>(
            [15, 2, 3, 4, 0.4, 0.3, 0.2, 0.1],
            (a, b) => (a - b).abs() < 1e-6,
            'close to',
          ),
        );
      });

      test('keeps the bounds it is given', () {
        final bounds = Aabb3.minMax(Vector3.all(-2), Vector3.all(2));
        final surface = StylizedMaterial.buildSurface(
          positions: [0, 0, 0, 1, 0, 0, 0, 1, 0],
          normals: List.filled(9, 0),
          indices: [0, 1, 2],
          material: StylizedMaterial(),
          aabb: bounds,
        );

        expect(surface.aabb.min, Vector3.all(-2));
        expect(surface.aabb.max, Vector3.all(2));
      });

      test('needs both joints and weights, with valid joints', () {
        Surface build({List<double>? joints, List<double>? weights}) =>
            StylizedMaterial.buildSurface(
              positions: [0, 0, 0],
              normals: [0, 0, 1],
              indices: [0, 0, 0],
              material: StylizedMaterial(),
              joints: joints,
              weights: weights,
            );

        expect(() => build(joints: [0, 0, 0, 0]), throwsArgumentError);
        expect(() => build(weights: [1, 0, 0, 0]), throwsArgumentError);
        expect(
          () => build(joints: [64, 0, 0, 0], weights: [1, 0, 0, 0]),
          throwsArgumentError,
        );
        expect(
          () => build(joints: [0.5, 0, 0, 0], weights: [1, 0, 0, 0]),
          throwsArgumentError,
        );
        expect(
          () => build(joints: [0, 0, 0], weights: [1, 0, 0, 0]),
          throwsArgumentError,
        );
        expect(
          build(joints: [3, 0, 0, 0], weights: [1, 0, 0, 0]).layout,
          StylizedMaterial.skinnedVertexLayout,
        );
      });

      test('rejects arrays of the wrong length', () {
        expect(
          () => StylizedMaterial.buildSurface(
            positions: [0, 0, 0, 1, 1, 1],
            normals: [0, 0, 1, 0, 0, 1],
            tint: [1],
            indices: [0, 1, 0],
            material: StylizedMaterial(),
          ),
          throwsArgumentError,
        );
        for (final (phase, flutter) in [
          ([0.0], null),
          (null, [0.0, 0.0, 0.0]),
        ]) {
          expect(
            () => StylizedMaterial.buildSurface(
              positions: [0, 0, 0, 1, 1, 1],
              normals: [0, 0, 1, 0, 0, 1],
              windPhase: phase,
              windFlutter: flutter,
              indices: [0, 1, 0],
              material: StylizedMaterial(),
            ),
            throwsArgumentError,
          );
        }
      });
    });
  });
}
