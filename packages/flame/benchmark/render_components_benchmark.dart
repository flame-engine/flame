import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:canvas_test/canvas_test.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'common.dart';

const _amountComponents = 500;
const _amountTicks = 2;
const _depthMultiplier = 0.25;

class RenderComponentsBenchmark(final Random random)
    extends AsyncBenchmarkBase {
  late final Canvas _canvas;
  late final FlameGame _game;

  this : super('Render Components Benchmark');

  static Future<void> main() async {
    final r = Random(69420);
    await RenderComponentsBenchmark(r).report();
  }

  @override
  Future<void> setup() async {
    _canvas = MockCanvas();

    _game = FlameGame();
    await mountGame(_game, size: Vector2.all(100.0));

    _game.addAll(
      List.generate(
        _amountComponents,
        (_) => _BenchmarkComponent(random: random, level: 1),
      ),
    );

    await _game.ready();
  }

  @override
  Future<void> run() async {
    for (var i = 0; i < _amountTicks; i++) {
      _game.render(_canvas);
    }
  }
}

class _BenchmarkComponent({
  required final Random random,
  required final double level,
}) extends PositionComponent {
  @override
  Future<void> onLoad() async {
    if (random.nextDouble() <= level) {
      addAll(
        List.generate(
          random.nextInt(2) + 1,
          (_) {
            return _BenchmarkComponent(
              random: random,
              level: level * _depthMultiplier,
            );
          },
        ),
      );
    }
  }
}

Future<void> main() => RenderComponentsBenchmark.main();
