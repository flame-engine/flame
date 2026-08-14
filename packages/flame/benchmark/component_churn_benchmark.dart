import 'dart:collection';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'common.dart';

const _dt = 1.0 / 60;

/// Measures the steady-state add/remove churn typical of bullets, particles
/// and spawners: every tick a batch of components is added, an older batch is
/// removed, and the game updates. This exercises the full lifecycle pipeline
/// (enqueueing, [FlameGame.processLifecycleEvents], loading, mounting,
/// unmounting) plus the children-container add and remove operations, amid a
/// stable population of live components.
///
/// The benchmark runs at two population sizes: removal cost inside one large
/// sibling container scales differently per container implementation (for
/// example, a sorted list shifts elements on every removal, while a tree does
/// a logarithmic lookup), so a container replacement must be evaluated at
/// both sizes.
class ComponentChurnBenchmark extends AsyncBenchmarkBase {
  static const _batchSize = 100;
  static const _liveBatches = 5;
  static const _amountTicks = 60;

  final int staticPopulation;
  late final FlameGame _game;
  final Queue<List<Component>> _batches = Queue();

  ComponentChurnBenchmark({required this.staticPopulation})
    : super(
        'Lifecycle churn '
        '(100 per tick, ${staticPopulation ~/ 1000}k population)',
      );

  static Future<void> main() async {
    await ComponentChurnBenchmark(staticPopulation: 1000).report();
    await ComponentChurnBenchmark(staticPopulation: 10000).report();
  }

  List<Component> _newBatch() {
    return List.generate(_batchSize, (_) => Component());
  }

  @override
  Future<void> setup() async {
    _game = FlameGame();
    await mountGame(_game);
    _game.world.addAll(
      List.generate(staticPopulation, (_) => Component()),
    );
    for (var i = 0; i < _liveBatches; i++) {
      final batch = _newBatch();
      _batches.addLast(batch);
      _game.world.addAll(batch);
    }
    await _game.ready();
  }

  @override
  Future<void> run() async {
    for (var i = 0; i < _amountTicks; i++) {
      _game.world.removeAll(_batches.removeFirst());
      final batch = _newBatch();
      _batches.addLast(batch);
      _game.world.addAll(batch);
      _game.update(_dt);
    }
  }
}

/// Measures bulk mounting and unmounting: 1000 components are added and
/// processed in one tick, then all removed and processed in the next. This
/// stresses [FlameGame.processLifecycleEvents] with a long event queue, as
/// happens when levels are loaded and torn down.
class MassAddRemoveBenchmark extends AsyncBenchmarkBase {
  static const _amountComponents = 1000;
  static const _amountCycles = 5;

  late final FlameGame _game;

  MassAddRemoveBenchmark() : super('Mass add/remove (1k per cycle)');

  static Future<void> main() async {
    await MassAddRemoveBenchmark().report();
  }

  @override
  Future<void> setup() async {
    _game = FlameGame();
    await mountGame(_game);
  }

  @override
  Future<void> run() async {
    for (var i = 0; i < _amountCycles; i++) {
      final components = List.generate(_amountComponents, (_) => Component());
      _game.world.addAll(components);
      _game.update(_dt);
      _game.world.removeAll(components);
      _game.update(_dt);
    }
  }
}

Future<void> main() async {
  await ComponentChurnBenchmark.main();
  await MassAddRemoveBenchmark.main();
}
