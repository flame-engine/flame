import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart' show RectangleComponent, World;
import 'package:flame/game.dart';
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter/widgets.dart' show GlobalKey, RepaintBoundary;
import 'package:flutter_test/flutter_test.dart';

import 'gpu_test_helpers.dart';

const _width = 160.0;
const _height = 120.0;
const _ground2D = Color(0xFF808080);

/// The projection of dimetric 2D art: scene points (i, j, z), z up.
Scene3DProjection _boardProjection() {
  return Scene3DProjection.affine(
    origin: Vector2(0, -18),
    xAxis: Vector2(44, 22),
    yAxis: Vector2(-44, 22),
    zAxis: Vector2(0, -53.889),
    towardsViewer: Vector3(0.6124, 0.6124, 0.5),
    near: -100,
    far: 100,
  );
}

/// A ground of [size] by [size] in the z = 0 plane of a z-up scene, centered
/// on [center].
MeshComponent _groundPlane(
  Material material, {
  required double size,
  Vector3? center,
}) {
  return MeshComponent(
    mesh: PlaneMesh(size: Vector2.all(size), material: material),
    position: center ?? Vector3.zero(),
    // The plane faces +y: turned to face +z.
    rotation: Quaternion.axisAngle(Vector3(1, 0, 0), math.pi / 2),
  );
}

/// The game's pixels of the last frame.
Future<Pixels> _capture(WidgetTester tester, GlobalKey key) async {
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  return (await tester.runAsync(() async {
    final image = await boundary.toImage();
    final pixels = await readImage(image);
    image.dispose();
    return pixels;
  }))!;
}

/// Shows [game] in a [_width] by [_height] view and pumps a few frames.
Future<GlobalKey> _show(WidgetTester tester, Game game) async {
  tester.view
    ..physicalSize = const Size(_width, _height)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final key = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: GameWidget(game: game),
    ),
  );
  for (var i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
  return key;
}

/// The red channel of the pixel at [position] (in logical pixels).
int _redAt(Pixels pixels, Vector2 position) {
  return pixels.at(position.x.floor(), position.y.floor()).$1;
}

void main() {
  setUpGpu();

  group('Shadows in a Scene3DComponent', () {
    /// A 2D gray ground below a layer with a shadow catcher, a red cube
    /// floating 1 to 2 above it at (2, 2) and a sun along (1, 0, -1).
    Future<(Pixels, Vector2 Function(Vector3))> renderCatcher(
      WidgetTester tester, {
      bool cubeCastsShadows = true,
      bool shadows = true,
    }) async {
      final layer = Scene3DComponent(
        projection: _boardProjection(),
        priority: 1,
      );
      layer.world.addAll([
        LightComponent.directional(
          direction: Vector3(1, 0, -1),
          shadows: shadows ? ShadowSettings() : null,
        ),
        _groundPlane(
          ShadowCatcherMaterial(),
          size: 10,
          center: Vector3(2, 2, 0),
        ),
        MeshComponent(
          mesh: CuboidMesh(
            size: Vector3.all(1),
            material: opaqueUnlit(const Color(0xFFFF0000)),
          ),
          position: Vector3(2, 2, 1.5),
          castsShadows: cubeCastsShadows,
        ),
      ]);
      final game = FlameGame(
        world: World(
          children: [
            RectangleComponent(
              position: Vector2.all(-5000),
              size: Vector2.all(10000),
              paint: Paint()..color = _ground2D,
            ),
            layer,
          ],
        ),
      );
      game.camera.viewfinder
        ..position = layer.positionOf(
          layer.scenePointToLocal(Vector3(3, 2, 0.7)),
        )
        ..zoom = 0.5;
      final key = await _show(tester, game);
      final pixels = await _capture(tester, key);
      Vector2 screen(Vector3 scenePoint) => game.camera.localToGlobal(
        layer.positionOf(layer.scenePointToLocal(scenePoint)),
      );
      return (pixels, screen);
    }

    testGpu('a catcher darkens the 2D ground in the shadow only', (
      tester,
    ) async {
      final (pixels, screen) = await renderCatcher(tester);

      // The cube spans heights 1 to 2: its shadow spans x 2.5 to 4.5 and
      // y 1.5 to 2.5 on the ground. Half opaque black over the gray.
      final darkened = (0x80 * (1 - 128 / 255)).round();
      expect(_redAt(pixels, screen(Vector3(3.5, 2, 0))), closeTo(darkened, 2));
      expect(
        _redAt(pixels, screen(Vector3(4.2, 2.3, 0))),
        closeTo(darkened, 2),
      );

      // Transparent elsewhere on the catcher: the 2D ground is untouched.
      for (final point in [
        Vector3(3.5, 3, 0),
        Vector3(3.5, 1, 0),
        Vector3(5, 2, 0),
        Vector3(4.5, 0.5, 0),
      ]) {
        expect(
          pixels.at(screen(point).x.floor(), screen(point).y.floor()),
          (0x80, 0x80, 0x80, 0xFF),
          reason: 'at $point',
        );
      }
      // The cube itself.
      expect(_redAt(pixels, screen(Vector3(2, 2, 2))), 0xFF);
    });

    testGpu('a catcher draws nothing without shadows', (tester) async {
      final (pixels, screen) = await renderCatcher(tester, shadows: false);
      expect(
        pixels.at(
          screen(Vector3(3.5, 2, 0)).x.floor(),
          screen(Vector3(3.5, 2, 0)).y.floor(),
        ),
        (0x80, 0x80, 0x80, 0xFF),
      );
    });

    testGpu('objects that do not cast shadows cast none', (tester) async {
      final (pixels, screen) = await renderCatcher(
        tester,
        cubeCastsShadows: false,
      );
      expect(_redAt(pixels, screen(Vector3(3.5, 2, 0))), 0x80);
      expect(_redAt(pixels, screen(Vector3(2, 2, 2))), 0xFF);
    });

    /// Renders a ground much larger than the view, with cubes on it, before
    /// and after panning the 2D camera by (3, 2) pixels, and returns the
    /// number of pixels that changed beyond the shift of the picture.
    Future<int> panDifference(
      WidgetTester tester, {
      required bool shadows,
      bool stabilize = true,
    }) async {
      final material = StylizedMaterial();
      final cube = CuboidMesh(size: Vector3(0.5, 0.5, 1), material: material);
      final layer = Scene3DComponent(projection: _boardProjection());
      layer.world.addAll([
        LightComponent.hemisphere(up: Vector3(0, 0, 1)),
        LightComponent.directional(
          direction: Vector3(0.8, 0.3, -1),
          intensity: 0.6,
          // A coarse map, whose texels cover several pixels.
          shadows: shadows
              ? ShadowSettings(resolution: 256, stabilize: stabilize)
              : null,
        ),
        _groundPlane(material, size: 40),
        for (var i = -3; i <= 3; i++)
          for (var j = -3; j <= 3; j++)
            MeshComponent(
              mesh: cube,
              position: Vector3(i * 1.7 + 0.3 * j, j * 1.3, 0.5),
            ),
      ]);
      final game = FlameGame(world: World(children: [layer]));
      final key = await _show(tester, game);
      final before = await _capture(tester, key);
      game.camera.moveBy(Vector2(3, 2));
      await tester.pump(const Duration(milliseconds: 16));
      final after = await _capture(tester, key);

      // The picture moved by (-3, -2).
      var changed = 0;
      for (var y = 0; y < before.height - 2; y++) {
        for (var x = 0; x < before.width - 3; x++) {
          final a = before.at(x + 3, y + 2);
          final b = after.at(x, y);
          if (a.$1 != b.$1 || a.$2 != b.$2 || a.$3 != b.$3) {
            changed++;
          }
        }
      }
      return changed;
    }

    testGpu('the shadows stay pixel-stable as the camera pans', (
      tester,
    ) async {
      final withoutShadows = await panDifference(tester, shadows: false);
      final stabilized = await panDifference(tester, shadows: true);
      final drifting = await panDifference(
        tester,
        shadows: true,
        stabilize: false,
      );
      debugPrint(
        'pixels changed by a pan: without shadows $withoutShadows, '
        'stabilized $stabilized, not stabilized $drifting',
      );
      expect(stabilized, lessThanOrEqualTo(withoutShadows));
      expect(drifting, greaterThan(stabilized + 20));
    });

    testGpu('costs one more pass with one draw call per caster surface', (
      tester,
    ) async {
      Future<(RenderStats, Duration)> render({required bool shadows}) async {
        final material = StylizedMaterial();
        final cube = CuboidMesh(size: Vector3.all(0.5), material: material);
        final layer = Scene3DComponent(projection: _boardProjection());
        layer.world.addAll([
          LightComponent.hemisphere(up: Vector3(0, 0, 1)),
          LightComponent.directional(
            direction: Vector3(0.8, 0.3, -1),
            shadows: shadows ? ShadowSettings() : null,
          ),
          _groundPlane(material, size: 12, center: Vector3(5, 5, 0)),
          for (var i = 0; i < 10; i++)
            for (var j = 0; j < 10; j++)
              MeshComponent(
                mesh: cube,
                position: Vector3(i + 0.5, j + 0.5, 0.25),
              ),
        ]);
        final game = FlameGame(world: World(children: [layer]));
        game.camera.viewfinder
          ..position = layer.scenePointToLocal(Vector3(5, 5, 0))
          ..zoom = 0.25;
        await _show(tester, game);
        // The CPU time of the last frames, once the pipelines are made.
        var time = Duration.zero;
        for (var i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 16));
          time += layer.lastRenderTime;
        }
        return (RenderStats()..setFrom(layer.renderStats), time ~/ 10);
      }

      final (plain, plainTime) = await render(shadows: false);
      final (shadowed, shadowedTime) = await render(shadows: true);
      debugPrint('100 cubes and a ground without shadows: $plain, $plainTime');
      debugPrint(
        '100 cubes and a ground with shadows: $shadowed, $shadowedTime',
      );

      expect(plain.renderPasses, 1);
      expect(plain.shadowPasses, 0);
      expect(shadowed.renderPasses, 2);
      expect(shadowed.shadowPasses, 1);
      // The ground and the hundred cubes in one instanced draw.
      expect(shadowed.shadowDrawCalls, 2);
      expect(shadowed.drawCalls, plain.drawCalls + 2);
      expect(shadowed.instances, plain.instances + 101);
    });
  });

  group('Shadows in a FlameGame3D', () {
    testGpu('a perspective camera sees the shadow where the sun puts it', (
      tester,
    ) async {
      final material = StylizedMaterial();
      final camera = CameraComponent3D(
        position: Vector3(0, 6, 6),
        target: Vector3.zero(),
        fovY: 50,
      );
      final cubeCenter = Vector3(0, 1.5, 0);
      final game = FlameGame3D(
        camera: camera,
        world: World3D(
          children: [
            LightComponent.hemisphere(intensity: 0.4),
            LightComponent.directional(
              direction: Vector3(1, -1, 0),
              intensity: 0.5,
              shadows: ShadowSettings(maxDistance: 30),
            ),
            MeshComponent(
              mesh: PlaneMesh(size: Vector2.all(8), material: material),
            ),
            MeshComponent(
              mesh: CuboidMesh(size: Vector3.all(1), material: material),
              position: cubeCenter,
            ),
          ],
        ),
      );
      tester.view
        ..physicalSize = const Size(160, 160)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: GameWidget(game: game),
        ),
      );
      for (var i = 0; i < 3; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      final pixels = await _capture(tester, key);

      // The cube spans heights 1 to 2 and x -0.5 to 0.5: its shadow spans
      // x 0.5 to 2.5 on the ground.
      final inShadow = camera.worldToViewportPoint(Vector3(1.5, 0, 0));
      final lit = camera.worldToViewportPoint(Vector3(-1.5, 0, 0));
      final litBeyond = camera.worldToViewportPoint(Vector3(3, 0, 0));
      expect(_redAt(pixels, inShadow), closeTo(102, 3));
      expect(_redAt(pixels, lit), greaterThan(150));
      expect(_redAt(pixels, litBeyond), greaterThan(150));
      expect(game.renderStats.renderPasses, 2);
      expect(game.renderStats.shadowPasses, 1);
    });
  });
}
