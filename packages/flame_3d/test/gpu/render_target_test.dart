import 'dart:ui' as ui;
import 'dart:ui' show Color, Size;

import 'package:flame/components.dart' show Component, World;
import 'package:flame/game.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d/src/graphics/backend/flutter_gpu/gpu_backend.dart'
    show debugColorTextureCount;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_test/flutter_test.dart';

import 'gpu_test_helpers.dart';

/// Statistics of a series of timings, in microseconds.
String _describe(String name, List<int> values) {
  final sorted = [...values]..sort();
  final mean = values.reduce((a, b) => a + b) / values.length;
  int at(double q) => sorted[((sorted.length - 1) * q).round()];
  return '$name: mean ${mean.toStringAsFixed(1)}, median ${at(0.5)}, '
      'p90 ${at(0.9)}, max ${sorted.last} us';
}

/// Moves its [target] along x a little every frame.
class _Mover(final MeshComponent target) extends Component {
  double time = 0;

  @override
  void update(double dt) {
    time += dt;
    target.position.x = 1 + 0.05 * (time * 10 % 3);
  }
}

void main() {
  setUpGpu();

  group('render targets', () {
    testGpuEngine('render many passes into at most three textures', () async {
      final device = GraphicsDevice();
      final context = RenderContext3D(device);
      final surface = quad(opaqueUnlit(const Color(0xFF3080C0)), halfSize: 0.1);
      // Flutter keeps the pictures of the frames it has yet to rasterize.
      final pictures = <ui.Picture>[];
      final beginPass = <int>[];
      final endPass = <int>[];
      final total = <int>[];
      final stopwatch = Stopwatch();

      for (var frame = 0; frame < 240; frame++) {
        device.begin();
        context.setCamera(defaultView, defaultProjection);
        stopwatch
          ..reset()
          ..start();
        device.beginPass(const Size(512, 384));
        final began = stopwatch.elapsedMicroseconds;
        for (var i = 0; i < 6; i++) {
          context.drawSurface(
            surface,
            transform: Matrix4.translationValues(-0.6 + i * 0.25, 0, -1),
          );
        }
        context.flush();
        final flushed = stopwatch.elapsedMicroseconds;
        final image = device.endPass();
        final ended = stopwatch.elapsedMicroseconds;
        device.end();

        final recorder = ui.PictureRecorder();
        ui.Canvas(recorder).drawImage(image, ui.Offset.zero, ui.Paint());
        pictures.add(recorder.endRecording());
        image.dispose();
        if (pictures.length > 2) {
          pictures.removeAt(0).dispose();
        }
        // The first frames create the textures and pipelines.
        if (frame >= 40) {
          beginPass.add(began);
          endPass.add(ended - flushed);
          total.add(ended);
        }
        // Let the GPU complete the frame, as a display would.
        await Future<void>.delayed(const Duration(milliseconds: 4));
      }
      for (final picture in pictures) {
        picture.dispose();
      }

      // Without Flutter frames to tell when an image is no longer drawn, the
      // texture rendered the longest ago is reused once there are three.
      expect(debugColorTextureCount(device.renderTarget), 3);
      debugPrint(
        [
          'Passes of 512x384 pixels with 6 draws, on this machine:',
          _describe('beginPass', beginPass),
          _describe('endPass', endPass),
          _describe('beginPass to endPass', total),
        ].join('\n'),
      );
    });

    testGpuEngine('keep the images of the last three passes', () async {
      final device = GraphicsDevice();
      final context = RenderContext3D(device);
      final squares = [
        (-0.5, quad(opaqueUnlit(const Color(0xFFFF0000)), halfSize: 0.2)),
        (0.0, quad(opaqueUnlit(const Color(0xFF00FF00)), halfSize: 0.2)),
        (0.5, quad(opaqueUnlit(const Color(0xFF0000FF)), halfSize: 0.2)),
      ];

      // Three passes into the same target, each drawing one square.
      final images = <ui.Image>[];
      for (final (x, surface) in squares) {
        device.begin();
        context.setCamera(defaultView, defaultProjection);
        device.beginPass(const Size(64, 64));
        context.drawSurface(
          surface,
          transform: Matrix4.translationValues(x, 0, -5),
        );
        context.flush();
        images.add(device.endPass());
        device.end();
      }

      for (final (i, image) in images.indexed) {
        final pixels = await readImage(image);
        image.dispose();
        for (final (j, (x, _)) in squares.indexed) {
          final (px, py) = pixelAt(x, 0);
          expect(
            pixels.isClear(px, py),
            i != j,
            reason: 'image $i, square $j',
          );
        }
      }
    });

    testGpu('reuse two textures when Flutter draws every frame', (
      tester,
    ) async {
      final mesh = MeshComponent(
        mesh: CuboidMesh(
          size: Vector3.all(0.5),
          material: opaqueUnlit(const Color(0xFFFF0000)),
        ),
        position: Vector3(1, 1, 0),
      );
      final layer = Scene3DComponent(
        projection: Scene3DProjection.affine(
          xAxis: Vector2(44, 22),
          yAxis: Vector2(-44, 22),
          zAxis: Vector2(0, -54),
          towardsViewer: Vector3(1, 1, 1),
          near: -50,
          far: 50,
        ),
      );
      layer.world.add(mesh);
      final game = FlameGame(world: World(children: [layer, _Mover(mesh)]));
      tester.view
        ..physicalSize = const Size(320, 240)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(GameWidget(game: game));
      final targets = <GpuRenderTarget>{};
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        if (layer.renderStats.renderPasses == 1) {
          targets.add(layer.device.renderTarget);
        }
      }

      // The object moves, the part of the screen the layer renders changes a
      // little: the target stays.
      expect(targets, hasLength(1));
      // An image is drawn by the frame it was rendered in, and rasterized
      // once two more frames have been drawn: two textures take turns.
      expect(debugColorTextureCount(targets.single), 2);
    });
  });
}
