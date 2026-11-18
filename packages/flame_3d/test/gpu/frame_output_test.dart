import 'dart:ui';

import 'package:flame/game.dart' show GameWidget;
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

import 'gpu_test_helpers.dart';

FlameGame3D _boxes({int count = 300, double renderScale = 1}) {
  final mesh = CuboidMesh(
    size: Vector3.all(0.3),
    material: SpatialMaterial(),
  );
  return FlameGame3D(
    world: World3D(
      renderScale: renderScale,
      children: [
        LightComponent.ambient(intensity: 0.5),
        LightComponent.point(position: Vector3(0, 0, 10), intensity: 50),
        for (var i = 0; i < count; i++)
          MeshComponent(
            mesh: mesh,
            position: Vector3((i % 20) - 9.5, (i ~/ 20) - 7, 0),
          ),
      ],
    ),
    camera: CameraComponent3D(
      position: Vector3(0, 0, 30),
      target: Vector3.zero(),
    ),
  );
}

void main() {
  setUpGpu();

  group('World3D', () {
    testGpu('draws 300 components sharing a mesh with one draw call', (
      tester,
    ) async {
      final game = _boxes();
      await renderGame(tester, game, width: 256, height: 256);

      expect(game.world.context.drawCount, 300);
      expect(game.renderStats.drawCalls, 1);
      expect(game.renderStats.instances, 300);
      expect(game.renderStats.triangles, 300 * 12);
      expect(game.renderStats.renderPasses, 1);
      expect(game.renderStats.pipelineChanges, 1);
      expect(game.renderStats.materialChanges, 1);
    });

    testGpu('rounds the render target size to whole pixels', (tester) async {
      // The game size is single precision: 97 / 1.1 becomes 88.1818161, and
      // back in physical pixels 96.9999977. Truncating it would render 96
      // pixels and stretch them over 97.
      tester.view
        ..physicalSize = const Size(97, 97)
        ..devicePixelRatio = 1.1;
      addTearDown(tester.view.reset);
      final game = _boxes(count: 1);
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump(const Duration(milliseconds: 16));

      expect(game.size.x * 1.1, lessThan(97));
      expect(game.device.renderTarget.width, 97);
      expect(game.device.renderTarget.height, 97);
    });

    testGpu('renders at a fraction of the device pixels', (tester) async {
      final game = _boxes(renderScale: 0.5);
      final pixels = await renderGame(tester, game);

      expect(game.device.renderTarget.width, 64);
      expect(game.device.renderTarget.height, 64);
      // The image is scaled back up to the whole view.
      expect(pixels.width, 128);
      final full = await renderGame(tester, _boxes());
      final covered = pixels.count((r, g, b, a) => a > 0);
      final fullCovered = full.count((r, g, b, a) => a > 0);
      expect(covered, closeTo(fullCovered, fullCovered * 0.1));
    });

    testGpu('rejects a render scale that is not positive', (tester) async {
      expect(() => World3D(renderScale: 0), throwsArgumentError);
      expect(() => World3D()..renderScale = -1, throwsArgumentError);
    });
  });

  group('frame output', () {
    testGpuEngine('keeps a frame intact while its image is held', () async {
      final device = GraphicsDevice();
      final context = RenderContext3D(device);
      final red = quad(opaqueUnlit(const Color(0xFFFF0000)));
      final blue = quad(opaqueUnlit(const Color(0xFF0000FF)));

      Future<Image> render(Surface surface) async {
        device.begin();
        context.setCamera(defaultView, defaultProjection);
        device.beginPass(const Size(16, 16));
        context
          ..drawSurface(surface, transform: Matrix4.translationValues(0, 0, -5))
          ..flush();
        final image = device.endPass();
        device.end();
        return image;
      }

      final first = await render(red);
      final second = await render(blue);
      final third = await render(red);

      expect((await readImage(first)).at(8, 8), (255, 0, 0, 255));
      expect((await readImage(second)).at(8, 8), (0, 0, 255, 255));
      expect((await readImage(third)).at(8, 8), (255, 0, 0, 255));
      first.dispose();
      second.dispose();
      third.dispose();
    });

    testGpuEngine('rounds the size of a pass to whole pixels', () async {
      final device = GraphicsDevice();
      device
        ..begin()
        ..beginPass(const Size(31.5, 20.4));
      final image = device.endPass();
      device.end();

      expect((image.width, image.height), (32, 20));
      image.dispose();
    });

    for (final msaa in [1, 4]) {
      testGpuEngine('renders with $msaa sample(s) per pixel', () async {
        final surface = quad(opaqueUnlit(const Color(0xFFFFFFFF)));
        final frame = await renderFrame(
          msaaSampleCount: msaa,
          draw: (context) => context.drawSurface(
            surface,
            transform: Matrix4.translationValues(0, 0, -5)..rotateZ(0.5),
          ),
        );

        final (x, y) = pixelAt(0, 0);
        expect(frame.pixels.at(x, y), (255, 255, 255, 255));
        final partial = frame.pixels.count((r, g, b, a) => a > 0 && a < 255);
        if (msaa == 1) {
          expect(partial, 0);
        } else {
          expect(partial, greaterThan(0));
        }
      });
    }
  });
}
