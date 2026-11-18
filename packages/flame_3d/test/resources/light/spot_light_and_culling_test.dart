import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_fakes/fake_gpu_backend.dart';

void main() {
  group('SpotLight, LightComponent.spot & nearest-light priority culling', () {
    late FakeGpuBackend backend;
    late GraphicsDevice device;
    late RenderContext3D context;
    late SpatialMaterial material;

    setUp(() {
      backend = FakeGpuBackend(blockSizes: {'JointMatrices': 4096});
      device = GraphicsDevice(backend: backend);
      context = RenderContext3D(device);
      material = SpatialMaterial();
    });

    Map<String, Float32List> drawLights(
      List<Light> lights, {
      Matrix4? view,
      Matrix4? projection,
      bool prioritize = false,
    }) {
      final surface = Surface(
        vertices: [
          Vertex(position: Vector3.zero(), texCoord: Vector2.zero()),
          Vertex(position: Vector3(1, 0, 0), texCoord: Vector2.zero()),
          Vertex(position: Vector3(0, 1, 0), texCoord: Vector2.zero()),
        ],
        indices: const [0, 1, 2],
        material: material,
      );
      device.begin();
      context
        ..prioritizeNearestLights = prioritize
        ..lights = lights
        ..setCamera(
          view ?? Matrix4.identity(),
          projection ?? Matrix4.identity(),
        );
      device.beginPass(const Size(16, 16));
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

    test('SpotLight packs position, -direction, color, cone & range', () {
      const inner = math.pi / 12;
      final rotatedDown = Matrix4.rotationX(-math.pi / 2);

      final uniforms = drawLights([
        Light(
          position: Vector3(2, 5, -3),
          source: SpotLight(
            color: const Color(0xFF00FF80),
            intensity: 4.0,
            range: 12.0,
            innerConeAngle: inner,
            direction: Vector3(0, -3, 0),
            specular: 0.75,
          ),
        ),
        // Zero intensity is skipped.
        Light(
          position: Vector3(9, 9, 9),
          source: SpotLight(intensity: 0),
        ),
        // Implicit direction from -Z axis of transform (`rotatedDown` -> -Y).
        Light(
          position: Vector3(-1, 4, 0),
          transform: rotatedDown,
          source: SpotLight(intensity: 2.0),
        ),
      ]);

      final spot = uniforms[RenderContext3D.spotLightsBlock]!;
      expect(spot[offsetOf('SpotLights', 'numLights')], 2.0);

      final posOff = offsetOf('SpotLights', 'positions');
      expect(spot.sublist(posOff, posOff + 3), [2.0, 5.0, -3.0]);
      expect(spot.sublist(posOff + 4, posOff + 7), [-1.0, 4.0, 0.0]);

      final dirOff = offsetOf('SpotLights', 'directions');
      // Shader stores `-direction` (pointing from surface towards the light).
      expect(spot[dirOff], closeTo(0.0, 1e-5));
      expect(spot[dirOff + 1], closeTo(1.0, 1e-5));
      expect(spot[dirOff + 2], closeTo(0.0, 1e-5));
      expect(spot[dirOff + 3], closeTo(0.75, 1e-5));

      expect(spot[dirOff + 4], closeTo(0.0, 1e-5));
      expect(spot[dirOff + 5], closeTo(1.0, 1e-5));
      expect(spot[dirOff + 6], closeTo(0.0, 1e-5));

      final coneOff = offsetOf('SpotLights', 'cones');
      final expectedCosOuter = math.cos(math.pi / 4);
      final expectedInvSpan = 1.0 / (math.cos(inner) - expectedCosOuter);
      expect(spot[coneOff], closeTo(expectedCosOuter, 1e-5));
      expect(spot[coneOff + 1], closeTo(expectedInvSpan, 1e-4));
      expect(spot[coneOff + 2], closeTo(12.0, 1e-5));
    });

    test(
      'prioritizeNearestLights selects nearest 8 of 32 PointLights '
      'and nearest 4 of 10 SpotLights',
      () {
        final view = Matrix4.translationValues(-100, 0, 0);
        final proj = makePerspectiveMatrix(math.pi / 3, 1.0, 0.1, 500.0);

        final lights = <Light>[
          for (var i = 0; i < 32; i++)
            Light(
              position: Vector3(i * 5.0, 0, 0),
              source: PointLight(
                color: const Color(0xFFFFFFFF),
                intensity: 2.0,
                range: 15.0,
              ),
            ),
          for (var i = 0; i < 10; i++)
            Light(
              position: Vector3(i * 12.0, 3, 0),
              source: SpotLight(intensity: 3.0, range: 20.0),
            ),
        ];

        final uniforms = drawLights(
          lights,
          view: view,
          projection: proj,
          prioritize: true,
        );

        final pt = uniforms[RenderContext3D.lightsBlock]!;
        expect(pt[offsetOf('Lights', 'numLights')], 8.0);
        final ptPosOff = offsetOf('Lights', 'positions');
        final selectedPtX = [
          for (var k = 0; k < 8; k++) pt[ptPosOff + k * 4],
        ];
        expect(selectedPtX.first, 100.0);
        for (final x in selectedPtX) {
          expect((x - 100.0).abs(), lessThanOrEqualTo(20.0));
        }

        final sp = uniforms[RenderContext3D.spotLightsBlock]!;
        expect(sp[offsetOf('SpotLights', 'numLights')], 4.0);
        final spPosOff = offsetOf('SpotLights', 'positions');
        final selectedSpX = [
          for (var k = 0; k < 4; k++) sp[spPosOff + k * 4],
        ];
        expect(selectedSpX.toSet(), {96.0, 108.0, 84.0, 72.0});
      },
    );

    test(
      'LightComponent.spot registers and updates world light transform',
      () async {
        final world = World3D();
        final game = FlameGame(world: world);
        final spotComp = LightComponent.spot(
          position: Vector3(1, 2, 3),
          intensity: 2.5,
          innerConeAngle: 0.2,
          outerConeAngle: 0.6,
        );
        world.add(spotComp);
        game
          ..onGameResize(Vector2.all(100))
          ..start();
        await game.ready();

        final recorder = PictureRecorder();
        world.renderScene(Canvas(recorder), overrideContext: context);
        recorder.endRecording().dispose();
        expect(context.lights, hasLength(1));
        expect(context.lights.single.source, isA<SpotLight>());

        final v0 = world.sceneVersion;
        spotComp.position.setValues(4, 5, 6);
        game.update(0.016);
        expect(context.lights.single.position.storage, [4.0, 5.0, 6.0]);
        expect(world.sceneVersion, greaterThan(v0));
      },
    );
  });
}
