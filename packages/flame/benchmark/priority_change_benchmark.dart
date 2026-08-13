import 'dart:math';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'common.dart';

const _dt = 1.0 / 60;
const _randomSeed = 69420;

/// Measures the cost of changing the priority of a single child in many
/// sibling containers: every tick, one child per parent gets a new priority
/// and the next update processes the resulting reorder events. Today each
/// changed parent pays a full rebalance of all its children, so this
/// benchmark captures the "one bullet changes z-order" worst case.
///
/// All priority values and child picks are precomputed in [setup] and replayed
/// identically on every run, so results are comparable across engine versions.
class SiblingPriorityChangeBenchmark extends AsyncBenchmarkBase {
  static const _amountParents = 100;
  static const _amountChildren = 50;
  static const _amountTicks = 50;

  late final FlameGame _game;
  late final List<List<Component>> _children;
  late final List<List<(int, int)>> _changes;

  SiblingPriorityChangeBenchmark()
    : super('Priority change (1 child per parent)');

  static Future<void> main() async {
    await SiblingPriorityChangeBenchmark().report();
  }

  @override
  Future<void> setup() async {
    final random = Random(_randomSeed);
    _game = FlameGame();
    await mountGame(_game);
    final parents = List.generate(
      _amountParents,
      (_) => Component(
        children: List.generate(
          _amountChildren,
          (i) => Component(priority: i),
        ),
      ),
    );
    _game.world.addAll(parents);
    await _game.ready();
    _children = [
      for (final parent in parents) parent.children.toList(growable: false),
    ];

    // For every tick, one (childIndex, newPriority) pair per parent.
    _changes = List.generate(_amountTicks, (_) {
      return List.generate(_amountParents, (_) {
        return (
          random.nextInt(_amountChildren),
          random.nextInt(_amountChildren * 20),
        );
      });
    });
  }

  @override
  Future<void> run() async {
    for (final tickChanges in _changes) {
      for (var parent = 0; parent < _amountParents; parent++) {
        final (childIndex, newPriority) = tickChanges[parent];
        _children[parent][childIndex].priority = newPriority;
      }
      _game.update(_dt);
    }
  }
}

/// Measures the y-sort pattern: every child of a single large container gets
/// a new priority every tick (as when sorting sprites by their y coordinate
/// while they move), followed by an update that reorders the whole container.
class YSortPriorityBenchmark extends AsyncBenchmarkBase {
  static const _amountChildren = 1000;
  static const _amountTicks = 30;

  late final FlameGame _game;
  late final List<Component> _children;
  late final List<List<int>> _priorities;

  YSortPriorityBenchmark() : super('Priority change (y-sort, all children)');

  static Future<void> main() async {
    await YSortPriorityBenchmark().report();
  }

  @override
  Future<void> setup() async {
    final random = Random(_randomSeed);
    _game = FlameGame();
    await mountGame(_game);
    _game.world.addAll(
      List.generate(_amountChildren, (i) => Component(priority: i)),
    );
    await _game.ready();
    _children = _game.world.children.toList(growable: false);

    // A fresh permutation of priorities for every tick, so almost every child
    // actually changes value (identical consecutive values are skipped by the
    // priority setter).
    _priorities = List.generate(_amountTicks, (_) {
      return List.generate(_amountChildren, (i) => i)..shuffle(random);
    });
  }

  @override
  Future<void> run() async {
    for (final tickPriorities in _priorities) {
      for (var i = 0; i < _children.length; i++) {
        _children[i].priority = tickPriorities[i];
      }
      _game.update(_dt);
    }
  }
}

Future<void> main() async {
  await SiblingPriorityChangeBenchmark.main();
  await YSortPriorityBenchmark.main();
}
