import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flame_3d/graphics.dart';
import 'package:flame_3d_example/showcase/showcase_diagnostics.dart';
import 'package:flame_3d_example/showcase/showcase_game.dart';
import 'package:flame_3d_example/showcase/showcase_variations.dart';
import 'package:flame_3d_example/showcase/showcase_view.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final gpuAvailable = GpuBackend.isAvailable;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    if (gpuAvailable) {
      await GpuBackend.initialize();
    }
  });

  testWidgets(
    'ShowcaseGame boots, exercises 16 labs, and passes 48/48 self-tests',
    (tester) async {
      tester.view
        ..physicalSize = const ui.Size(800, 520)
        ..devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final game = ShowcaseGame();
      addTearDown(game.controller.dispose);
      final boundaryKey = GlobalKey();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: RepaintBoundary(
            key: boundaryKey,
            child: ShowcaseView(game: game),
          ),
        ),
      );

      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(game.isLoaded, isTrue);
      expect(ShowcasePreset.values, hasLength(16));

      final report = await ShowcaseDiagnostics.runAllChecks(
        game,
        pumpFrame: () => tester.pump(const Duration(milliseconds: 16)),
        runAsyncHost: tester.runAsync,
        readImageBytes: (img) =>
            tester.runAsync<ByteData?>(() => img.toByteData()),
      );

      final failedDetails = report.results
          .where((r) => !r.passed)
          .map((r) => '${r.id}: ${r.detail}')
          .join('\n');
      expect(
        report.allPassed,
        isTrue,
        reason: 'Failed showcase checks:\n$failedDetails',
      );
      expect(report.totalCount, 48);

      // Verify 2,048-instance + 6-rig extreme stress lab renders and paints
      // visible pixels into the frame!
      game.applyPreset(ShowcasePreset.extremeStress);
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 16));
      expect(game.tileInstances.length, 2048);
      expect(
        game.staticLayer.renderStats.instances,
        greaterThanOrEqualTo(2048),
      );
      expect(game.variationRig.extraSkinnedRigs, hasLength(6));

      final boundary =
          boundaryKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      final nonDarkPixels = await tester.runAsync(() async {
        final image = await boundary.toImage();
        final data = await image.toByteData();
        image.dispose();
        final bytes = data!.buffer.asUint8List();
        var count = 0;
        for (var i = 0; i + 3 < bytes.length; i += 4) {
          if (bytes[i] > 60 || bytes[i + 1] > 60 || bytes[i + 2] > 80) {
            count++;
          }
        }
        return count;
      });
      expect(nonDarkPixels, greaterThan(5000));
    },
    skip: !gpuAvailable,
  );
}
