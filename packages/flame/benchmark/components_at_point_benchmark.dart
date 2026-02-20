import 'dart:math';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

const _maxDepth = 10;
const _amountHitTests = 500;
const _gameSize = 800.0;

/// Baseline: no hit testing, just two componentsAtPoint calls per position
/// (tap down + tap up delivery). Represents pre-PR behavior where the game
/// caught all events without checking which component was hit.
/// See PR: https://github.com/flame-engine/flame/pull/3815
class BaselineBenchmark extends AsyncBenchmarkBase {
  final Random random;

  late final FlameGame _game;
  late final List<Vector2> _positions;

  BaselineBenchmark(this.random) : super('Baseline (no hit test)');

  static Future<void> main() async {
    final r = Random(69420);
    await BaselineBenchmark(r).report();
  }

  @override
  Future<void> setup() async {
    _game = _buildGame();
    await _game.ready();
    _positions = _generatePositions(random);
  }

  @override
  Future<void> run() async {
    for (final position in _positions) {
      // Tap down delivery only.
      final trace1 = <Vector2>[];
      for (final component in _game.componentsAtPoint(position, trace1)) {
        if (component is TapCallbacks) {
          break;
        }
      }

      // Tap up delivery only.
      final trace2 = <Vector2>[];
      for (final component in _game.componentsAtPoint(position, trace2)) {
        if (component is TapCallbacks) {
          break;
        }
      }
    }
  }
}

/// Benchmarks the real flow: containsEventHandlerAt (hit test with early-stop
/// and caching) followed by two componentsAtPoint calls (tap down replays
/// from cache, tap up does a real traversal).
class CachedHitTestBenchmark extends AsyncBenchmarkBase {
  final Random random;

  late final FlameGame _game;
  late final List<Vector2> _positions;

  CachedHitTestBenchmark(this.random) : super('Hit Test + Delivery (cached)');

  static Future<void> main() async {
    final r = Random(69420);
    await CachedHitTestBenchmark(r).report();
  }

  @override
  Future<void> setup() async {
    _game = _buildGame();
    await _game.ready();
    _positions = _generatePositions(random);
  }

  @override
  Future<void> run() async {
    for (final position in _positions) {
      final hasHandler = _game.containsEventHandlerAt(position);

      // Simulate tap down delivery.
      final trace1 = <Vector2>[];
      for (final component in _game.componentsAtPoint(position, trace1)) {
        if (component is TapCallbacks) {
          break;
        }
      }

      // Simulate tap up delivery.
      if (hasHandler) {
        final trace2 = <Vector2>[];
        for (final component in _game.componentsAtPoint(position, trace2)) {
          if (component is TapCallbacks) {
            break;
          }
        }
      }
    }
  }
}

/// Benchmarks the flow without cache: componentsAtPoint called 3 times
/// per tap (hit test scan + tap down delivery + tap up delivery).
class UncachedHitTestBenchmark extends AsyncBenchmarkBase {
  final Random random;

  late final FlameGame _game;
  late final List<Vector2> _positions;

  UncachedHitTestBenchmark(this.random)
    : super('Hit Test + Delivery (uncached)');

  static Future<void> main() async {
    final r = Random(69420);
    await UncachedHitTestBenchmark(r).report();
  }

  @override
  Future<void> setup() async {
    _game = _buildGame();
    await _game.ready();
    _positions = _generatePositions(random);
  }

  @override
  Future<void> run() async {
    for (final position in _positions) {
      // Simulate old hit test: plain componentsAtPoint scan (no cache write).
      var hasHandler = false;
      final trace0 = <Vector2>[];
      for (final component in _game.componentsAtPoint(position, trace0)) {
        if (component is TapCallbacks ||
            component is DragCallbacks ||
            component is DoubleTapCallbacks ||
            component is ScaleCallbacks ||
            component is SecondaryTapCallbacks) {
          hasHandler = true;
          break;
        }
      }

      // Simulate tap down delivery.
      final trace1 = <Vector2>[];
      for (final component in _game.componentsAtPoint(position, trace1)) {
        if (component is TapCallbacks) {
          break;
        }
      }

      // Simulate tap up delivery.
      if (hasHandler) {
        final trace2 = <Vector2>[];
        for (final component in _game.componentsAtPoint(position, trace2)) {
          if (component is TapCallbacks) {
            break;
          }
        }
      }
    }
  }
}

FlameGame _buildGame() {
  final random = Random(12345);
  final game = FlameGame();
  game.onGameResize(Vector2.all(_gameSize));

  // Build a tree 10 levels deep with varied sizes and positions.
  // Each level has 3-4 children that subdivide the parent's area,
  // with tappable leaves scattered throughout.
  void buildTree(PositionComponent parent, int depth, double size) {
    if (depth >= _maxDepth) {
      return;
    }
    final childCount = 1 + random.nextInt(2); // 1 or 2 children
    final childSize = size * (0.3 + random.nextDouble() * 0.3); // 30-60%
    for (var i = 0; i < childCount; i++) {
      final maxOffset = size - childSize;
      final pos = Vector2(
        random.nextDouble() * maxOffset.clamp(0, double.infinity),
        random.nextDouble() * maxOffset.clamp(0, double.infinity),
      );
      final PositionComponent child;
      if (depth == _maxDepth - 1 && i % 3 == 0) {
        child = _TappableComponent()
          ..position = pos
          ..size = Vector2.all(childSize);
      } else {
        child = PositionComponent()
          ..position = pos
          ..size = Vector2.all(childSize);
      }
      parent.add(child);
      buildTree(child, depth + 1, childSize);
    }
  }

  // Create several top-level subtrees.
  for (var i = 0; i < 4; i++) {
    final root = PositionComponent()
      ..position = Vector2(
        (i % 2) * _gameSize / 2,
        (i ~/ 2) * _gameSize / 2,
      )
      ..size = Vector2.all(_gameSize / 2);
    game.add(root);
    buildTree(root, 1, _gameSize / 2);
  }

  return game;
}

List<Vector2> _generatePositions(Random random) {
  return List.generate(
    _amountHitTests,
    (_) => Vector2(
      random.nextDouble() * _gameSize,
      random.nextDouble() * _gameSize,
    ),
  );
}

class _TappableComponent extends PositionComponent with TapCallbacks {}

Future<void> main() async {
  final r1 = Random(69420);
  await BaselineBenchmark(r1).report();

  final r2 = Random(69420);
  await CachedHitTestBenchmark(r2).report();

  final r3 = Random(69420);
  await UncachedHitTestBenchmark(r3).report();
}
