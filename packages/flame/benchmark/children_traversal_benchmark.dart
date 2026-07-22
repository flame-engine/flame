import 'dart:ui';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:canvas_test/canvas_test.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'common.dart';

const _dt = 1.0 / 60;

/// These benchmarks measure the pure engine cost of the update and render
/// passes: iterating the children containers, the `updateTree`/`renderTree`
/// recursion, and the per-tick lifecycle-queue check. All components are
/// plain [Component]s with no-op [Component.update] and [Component.render],
/// so any time measured here is framework overhead rather than game logic.
///
/// The tree shapes stress different aspects of the traversal:
/// - wide: one container holding many children (container iteration cost),
/// - nested: many small containers (iterator setup cost per parent),
/// - deep: a long parent chain (recursion depth cost),
/// - barrier: a nested tree where a fraction of the parents override
///   `updateTree` (via [HasTimeScale]). This is the realistic case for
///   evaluating flattened traversal designs, since components like
///   `SequenceEffect`, `Route`, and `HasTimeScale` users manage their own
///   subtree traversal and cannot be inlined into a flat list.
///
/// Each run performs roughly one million component visits, so the reported
/// times are comparable across shapes and between the two passes.
abstract class _TraversalBenchmark extends AsyncBenchmarkBase {
  _TraversalBenchmark(
    super.name, {
    required this.ticks,
    required this.renderPass,
  });

  final int ticks;
  final bool renderPass;
  late final FlameGame _game;
  late final Canvas _canvas;

  /// Builds the component tree under [world] and returns the total number of
  /// components added.
  int buildTree(World world);

  @override
  Future<void> setup() async {
    _canvas = MockCanvas();
    _game = FlameGame();
    await mountGame(_game);
    buildTree(_game.world);
    await _game.ready();
  }

  @override
  Future<void> run() async {
    if (renderPass) {
      for (var i = 0; i < ticks; i++) {
        _game.render(_canvas);
      }
    } else {
      for (var i = 0; i < ticks; i++) {
        _game.update(_dt);
      }
    }
  }
}

/// 10k components in a single children container.
class WideTreeBenchmark extends _TraversalBenchmark {
  static const _amountChildren = 10000;

  WideTreeBenchmark({required super.renderPass})
    : super(
        '${renderPass ? 'Render' : 'Update'} wide tree (10k x 1)',
        ticks: 100,
      );

  static Future<void> main() async {
    await WideTreeBenchmark(renderPass: false).report();
    await WideTreeBenchmark(renderPass: true).report();
  }

  @override
  int buildTree(World world) {
    world.addAll(List.generate(_amountChildren, (_) => Component()));
    return _amountChildren;
  }
}

/// 1k parents with 10 children each: many small children containers.
class NestedTreeBenchmark extends _TraversalBenchmark {
  static const _amountParents = 1000;
  static const _amountChildren = 10;

  NestedTreeBenchmark({required super.renderPass})
    : super(
        '${renderPass ? 'Render' : 'Update'} nested tree (1k x 10)',
        ticks: 90,
      );

  static Future<void> main() async {
    await NestedTreeBenchmark(renderPass: false).report();
    await NestedTreeBenchmark(renderPass: true).report();
  }

  @override
  int buildTree(World world) {
    world.addAll(
      List.generate(
        _amountParents,
        (_) => Component(
          children: List.generate(_amountChildren, (_) => Component()),
        ),
      ),
    );
    return _amountParents * (_amountChildren + 1);
  }
}

/// A chain 100 levels deep where every level also holds 9 leaf children.
class DeepTreeBenchmark extends _TraversalBenchmark {
  static const _depth = 100;
  static const _leavesPerLevel = 9;

  DeepTreeBenchmark({required super.renderPass})
    : super(
        '${renderPass ? 'Render' : 'Update'} deep tree (100 levels)',
        ticks: 1000,
      );

  static Future<void> main() async {
    await DeepTreeBenchmark(renderPass: false).report();
    await DeepTreeBenchmark(renderPass: true).report();
  }

  @override
  int buildTree(World world) {
    // Build the chain bottom-up so each level is created with its children.
    Component? next;
    for (var level = 0; level < _depth; level++) {
      next = Component(
        children: [
          ...List.generate(_leavesPerLevel, (_) => Component()),
          if (next != null) next,
        ],
      );
    }
    world.add(next!);
    return _depth * (_leavesPerLevel + 1);
  }
}

/// Same shape as the nested tree, but every 10th parent overrides
/// `updateTree` through [HasTimeScale] (with the time scale left at 1.0, so
/// the traversal work stays identical and only the override indirection is
/// measured).
class BarrierTreeUpdateBenchmark extends _TraversalBenchmark {
  static const _amountParents = 1000;
  static const _amountChildren = 10;
  static const _barrierInterval = 10;

  BarrierTreeUpdateBenchmark()
    : super(
        'Update barrier tree (1k x 10, 10% time-scaled)',
        ticks: 90,
        renderPass: false,
      );

  static Future<void> main() async {
    await BarrierTreeUpdateBenchmark().report();
  }

  @override
  int buildTree(World world) {
    world.addAll(
      List.generate(_amountParents, (i) {
        final children = List.generate(_amountChildren, (_) => Component());
        return i % _barrierInterval == 0
            ? _TimeScaledParent(children: children)
            : Component(children: children);
      }),
    );
    return _amountParents * (_amountChildren + 1);
  }
}

class _TimeScaledParent extends Component with CustomTraversal, HasTimeScale {
  _TimeScaledParent({super.children});
}

Future<void> main() async {
  await WideTreeBenchmark.main();
  await NestedTreeBenchmark.main();
  await DeepTreeBenchmark.main();
  await BarrierTreeUpdateBenchmark.main();
}
