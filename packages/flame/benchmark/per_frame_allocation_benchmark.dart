import 'dart:typed_data';
import 'dart:ui';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/rendering.dart';

import 'common.dart';

const _dt = 1.0 / 60;

/// These benchmarks isolate the per-frame allocation overhead of the render
/// and update passes: work that the engine performs on every single frame
/// even when the game itself does nothing.
///
/// - The render suite draws a wide tree of decorated components onto a canvas
///   that discards every call. A `PositionComponent` routes its render through
///   `Decorator.applyChain`, so any closure or tear-off allocated on the way
///   to it is paid once per component per frame, and with the no-op canvas
///   those allocations are a large share of the measured time. The tree mixes
///   bare [PositionComponent]s with [HasDecorator] components carrying a
///   [PaintDecorator], so that the `Decorator.apply` call site stays
///   polymorphic like in a real game, rather than letting the optimizer
///   devirtualize the single-decorator case and sink the allocations.
/// - The update suite ticks a game with an empty component tree and an empty
///   lifecycle queue, which isolates the fixed per-tick bookkeeping cost of
///   `processLifecycleEvents` and friends from any traversal work.
class RenderDecoratedComponentsBenchmark extends AsyncBenchmarkBase {
  static const _amountComponents = 10000;
  static const _ticks = 20;

  late final FlameGame _game;
  late final Canvas _canvas;

  RenderDecoratedComponentsBenchmark()
    : super('Render wide tree of decorated components (10k x 1)');

  static Future<void> main() async {
    await RenderDecoratedComponentsBenchmark().report();
  }

  @override
  Future<void> setup() async {
    _canvas = _NoopCanvas();
    _game = FlameGame();
    await mountGame(_game);
    _game.world.addAll(
      List.generate(
        _amountComponents,
        (i) => i.isEven ? PositionComponent() : _TintedComponent(),
      ),
    );
    await _game.ready();
  }

  @override
  Future<void> run() async {
    for (var i = 0; i < _ticks; i++) {
      _game.render(_canvas);
    }
  }
}

/// A game with nothing in it: each tick only pays the fixed per-tick cost of
/// the camera/world scaffolding and the lifecycle-queue check.
class EmptyLifecycleQueueTickBenchmark extends AsyncBenchmarkBase {
  static const _ticks = 10000;

  late final FlameGame _game;

  EmptyLifecycleQueueTickBenchmark()
    : super('Update empty game (10k ticks, empty lifecycle queue)');

  static Future<void> main() async {
    await EmptyLifecycleQueueTickBenchmark().report();
  }

  @override
  Future<void> setup() async {
    _game = FlameGame();
    await mountGame(_game);
  }

  @override
  Future<void> run() async {
    for (var i = 0; i < _ticks; i++) {
      _game.update(_dt);
    }
  }
}

class _TintedComponent extends Component with HasDecorator {
  _TintedComponent() {
    decorator = PaintDecorator.tint(const Color(0x44000000));
  }
}

/// A canvas that discards every call. `MockCanvas` from `canvas_test` records
/// a command list and rescans it on every transform, which both allocates per
/// call and slows down as the list grows; a benchmark that measures
/// engine-side allocations needs the canvas itself to be allocation-free.
///
/// The hot-path methods of the `PositionComponent` render chain (save,
/// transform, restore) are implemented explicitly so that they do not go
/// through [noSuchMethod], which would allocate an [Invocation] per call.
class _NoopCanvas implements Canvas {
  int _saveCount = 1;

  @override
  void save() => _saveCount++;

  @override
  void restore() => _saveCount--;

  @override
  int getSaveCount() => _saveCount;

  @override
  void saveLayer(Rect? bounds, Paint paint) => _saveCount++;

  @override
  void transform(Float64List matrix4) {}

  @override
  void translate(double dx, double dy) {}

  @override
  void scale(double sx, [double? sy]) {}

  @override
  void clipRect(
    Rect rect, {
    ClipOp clipOp = ClipOp.intersect,
    bool doAntiAlias = true,
  }) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Future<void> main() async {
  await RenderDecoratedComponentsBenchmark.main();
  await EmptyLifecycleQueueTickBenchmark.main();
}
