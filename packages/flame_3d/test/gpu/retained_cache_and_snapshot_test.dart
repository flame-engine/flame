import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart' show RectangleComponent, World;
import 'package:flame/game.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter/widgets.dart' show GlobalKey, RepaintBoundary;
import 'package:flutter_test/flutter_test.dart';

import 'gpu_test_helpers.dart';

Scene3DProjection _isoProjection() => Scene3DProjection.affine(
  origin: Vector2(64, 64),
  xAxis: Vector2(24, 12),
  yAxis: Vector2(-24, 12),
  zAxis: Vector2(0, -28),
  towardsViewer: Vector3(1, 1, 1),
  near: -50,
  far: 50,
);

void main() {
  setUpGpu();

  group('Retained Scene3DComponent, static shadow cache & renderToImage', () {
    testGpu('Scene3DCacheMode.retained skips GPU passes until dirtied', (
      tester,
    ) async {
      final cube = MeshComponent(
        mesh: CuboidMesh(
          size: Vector3.all(1.2),
          material: UnlitMaterial(albedoColor: const Color(0xFFE03030)),
        ),
      );
      final layer = Scene3DComponent(
        projection: _isoProjection(),
        cacheMode: Scene3DCacheMode.retained,
      );
      layer.world.add(cube);

      // An animated 2D sibling forces Flutter to repaint every pumped frame.
      final ticker2D = RectangleComponent(
        size: Vector2.all(4),
        paint: Paint()..color = const Color(0xFF202020),
      );
      final game = FlameGame(world: World(children: [ticker2D, layer]));
      game.camera.viewfinder.position = Vector2(64, 64);

      tester.view
        ..physicalSize = const Size(128, 128)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: GameWidget(game: game),
        ),
      );
      await tester.pump(const Duration(milliseconds: 16));
      expect(layer.renderStats.renderPasses, 1);
      expect(layer.cacheHitCount, 0);

      for (var i = 0; i < 3; i++) {
        ticker2D.position.x += 2;
        await tester.pump(const Duration(milliseconds: 16));
        expect(layer.renderStats.renderPasses, 0);
      }
      expect(layer.cacheHitCount, 3);

      // Moving the 3D cube invalidates `world.sceneVersion` and renders fresh.
      cube.position.x = 1.0;
      ticker2D.position.x += 2;
      await tester.pump(const Duration(milliseconds: 16));
      expect(layer.renderStats.renderPasses, 1);

      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final pixels = (await tester.runAsync(() async {
        final image = await boundary.toImage();
        final data = await image.toByteData();
        final out = Pixels(
          image.width,
          image.height,
          data!.buffer.asUint8List(),
        );
        image.dispose();
        return out;
      }))!;
      expect(pixels.count((r, g, b, a) => r > 180 && g < 80), greaterThan(100));
    });

    testGpu('ShadowSettings.cacheWhenStatic skips unchanged shadow passes', (
      tester,
    ) async {
      final caster = MeshComponent(
        mesh: CuboidMesh(
          size: Vector3.all(1.0),
          material: StylizedMaterial(albedoColor: const Color(0xFFE0C080)),
        ),
        position: Vector3(0, 0, 0.5),
      );
      final ground = MeshComponent(
        mesh: PlaneMesh(
          size: Vector2.all(8),
          material: ShadowCatcherMaterial(color: const Color(0xC0000000)),
        ),
        rotation: Quaternion.axisAngle(Vector3(1, 0, 0), math.pi / 2),
      );
      final sun = LightComponent.directional(
        direction: Vector3(0.5, -0.5, -1.0),
        shadows: ShadowSettings(cacheWhenStatic: true),
      );

      final layer = Scene3DComponent(projection: _isoProjection());
      layer.world.addAll([
        LightComponent.ambient(intensity: 0.4),
        sun,
        ground,
        caster,
      ]);

      final ticker2D = RectangleComponent(
        size: Vector2.all(128),
        paint: Paint()..color = const Color(0xFF90A090),
      );
      final game = FlameGame(world: World(children: [ticker2D, layer]));
      game.camera.viewfinder.position = Vector2(64, 64);

      tester.view
        ..physicalSize = const Size(128, 128)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: GameWidget(game: game),
        ),
      );
      await tester.pump(const Duration(milliseconds: 16));
      expect(layer.renderStats.shadowPasses, 1);

      // Subsequent frame with non-shadow mutation: main pass runs, shadow pass
      // is served from the static shadow cache (`0` shadowPasses), and shadows
      // remain visible on the ground!
      layer.world.markSceneDirty(shadows: false);
      ticker2D.paint.color = const Color(0xFF91A090);
      await tester.pump(const Duration(milliseconds: 16));
      expect(layer.renderStats.renderPasses, 1);
      expect(layer.renderStats.shadowPasses, 0);

      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final cachedPixels = (await tester.runAsync(() async {
        final image = await boundary.toImage();
        final data = await image.toByteData();
        final out = Pixels(
          image.width,
          image.height,
          data!.buffer.asUint8List(),
        );
        image.dispose();
        return out;
      }))!;
      // Darkened shadow pixels on the 0xFF91A090 ground.
      expect(
        cachedPixels.count((r, g, b, a) => g < 110 && r < 110),
        greaterThan(60),
      );

      // Moving the caster invalidates `castersVersion` and re-renders shadows.
      caster.position.x = 0.8;
      await tester.pump(const Duration(milliseconds: 16));
      expect(layer.renderStats.shadowPasses, 1);
    });

    testGpuEngine(
      'Scene3DComponent.renderToImage captures isolated snapshots',
      () async {
        final redLayer = Scene3DComponent(projection: _isoProjection());
        redLayer.world.add(
          MeshComponent(
            mesh: CuboidMesh(
              size: Vector3.all(1.5),
              material: UnlitMaterial(albedoColor: const Color(0xFFFF1010)),
            ),
          ),
        );

        final blueLayer = Scene3DComponent(projection: _isoProjection());
        blueLayer.world.add(
          MeshComponent(
            mesh: CuboidMesh(
              size: Vector3.all(1.5),
              material: UnlitMaterial(albedoColor: const Color(0xFF1020FF)),
            ),
          ),
        );

        final redImg = redLayer.renderToImage(const Size(128, 128));
        final blueImg = blueLayer.renderToImage(const Size(128, 128));

        final redBytes = (await redImg.toByteData())!.buffer.asUint8List();
        final blueBytes = (await blueImg.toByteData())!.buffer.asUint8List();
        redImg.dispose();
        blueImg.dispose();

        final redPixels = Pixels(128, 128, redBytes);
        final bluePixels = Pixels(128, 128, blueBytes);

        // Rendering `blueLayer` did NOT overwrite `redImg`'s backing texture!
        expect(
          redPixels.count((r, g, b, a) => r > 200 && b < 40),
          greaterThan(200),
        );
        expect(
          bluePixels.count((r, g, b, a) => b > 200 && r < 40),
          greaterThan(200),
        );
      },
    );
  });
}
