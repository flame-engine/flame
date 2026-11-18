// Measures what rendering the benchmark scene costs, see README.md.
//
//   flutter test --enable-impeller --enable-flutter-gpu \
//     [--enable-vmservice] [--dart-define=FLAME_3D_PROFILE=true] \
//     benchmark/scene_benchmark_test.dart
//

import 'dart:ui' as ui;

import 'package:flame/game.dart' show GameWidget;
import 'package:flame_3d/graphics.dart';
import 'package:flutter/widgets.dart' show Directionality, TextDirection;
import 'package:flutter_test/flutter_test.dart';

import 'benchmark_runner.dart';
import 'scene_benchmark.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final available = GpuBackend.isAvailable;

  setUpAll(() async {
    if (available) {
      await GpuBackend.initialize();
    }
  });

  final run = BenchmarkRun();
  tearDownAll(run.save);
  final config = BenchmarkRun.config;
  const mode = BenchmarkRun.mode;

  testWidgets(
    'CPU per frame',
    (tester) async {
      // A low pixel ratio keeps the software GPU quick: the CPU work does
      // not depend on it.
      final game = await _start(
        tester,
        config,
        width: 390,
        height: 844,
        pixelRatio: 0.5,
      );
      await tester.runAsync(() async {
        await run.cpu(game);
        if (mode == 'alloc' || mode == 'all') {
          await run.allocations(game);
        }
      });
    },
    skip: !available || !(mode == 'cpu' || mode == 'all' || mode == 'alloc'),
    timeout: const Timeout(Duration(minutes: 20)),
  );

  testWidgets(
    'GPU per frame at phone resolution',
    (tester) async {
      final game = await _start(
        tester,
        config,
        width: 390,
        height: 844,
        pixelRatio: 3,
      );
      await tester.runAsync(() => run.gpu(game));
    },
    skip: !available || !(mode == 'gpu' || mode == 'all'),
    timeout: const Timeout(Duration(minutes: 20)),
  );
}

Future<BenchmarkGame> _start(
  WidgetTester tester,
  BenchmarkConfig config, {
  required double width,
  required double height,
  double pixelRatio = 1,
}) async {
  tester.view
    ..physicalSize = ui.Size(width * pixelRatio, height * pixelRatio)
    ..devicePixelRatio = pixelRatio;
  addTearDown(tester.view.reset);
  final game = BenchmarkGame(config);
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: GameWidget(game: game),
    ),
  );
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
  return game;
}
