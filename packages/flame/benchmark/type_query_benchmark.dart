import 'dart:collection';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'common.dart';

const _dt = 1.0 / 60;

/// Measures the per-type query caches of the children container
/// (`children.register<T>()` / `children.query<T>()`), which Flame uses
/// internally for hitboxes (`GestureHitboxes`), post-processing
/// (`CameraComponent`), and layout (`LinearLayoutComponent`).
///
/// Every add and remove has to update all registered caches, so this
/// benchmark churns a mixed-type population in a container with two
/// registered queries while reading one query per tick. A children-container
/// replacement must keep both the cache-maintenance and the query-read cost
/// at least this fast.
class TypeQueryChurnBenchmark extends AsyncBenchmarkBase {
  static const _amountStatic = 1000;
  static const _batchSize = 50;
  static const _liveBatches = 5;
  static const _amountTicks = 60;
  static const _markedInterval = 5;

  late final FlameGame _game;
  final Queue<List<Component>> _batches = Queue();

  TypeQueryChurnBenchmark() : super('Type-query churn (2 registered queries)');

  static Future<void> main() async {
    await TypeQueryChurnBenchmark().report();
  }

  List<Component> _newBatch() {
    return List.generate(
      _batchSize,
      (i) => i % _markedInterval == 0 ? _MarkedComponent() : _PlainComponent(),
    );
  }

  @override
  Future<void> setup() async {
    _game = FlameGame();
    await mountGame(_game);
    _game.world.children.register<_MarkedComponent>();
    _game.world.children.register<_PlainComponent>();
    _game.world.addAll(
      List.generate(
        _amountStatic,
        (i) =>
            i % _markedInterval == 0 ? _MarkedComponent() : _PlainComponent(),
      ),
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
    var visited = 0;
    for (var i = 0; i < _amountTicks; i++) {
      _game.world.removeAll(_batches.removeFirst());
      final batch = _newBatch();
      _batches.addLast(batch);
      _game.world.addAll(batch);
      for (final marked in _game.world.children.query<_MarkedComponent>()) {
        visited += marked.marker;
      }
      _game.update(_dt);
    }
    assert(visited > 0);
  }
}

class _MarkedComponent extends Component {
  final int marker = 1;
}

class _PlainComponent extends Component {}

Future<void> main() async {
  await TypeQueryChurnBenchmark.main();
}
