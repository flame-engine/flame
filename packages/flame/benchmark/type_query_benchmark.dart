import 'dart:collection';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'common.dart';

const _dt = 1.0 / 60;

/// Builds a population of [amount] components in which one in five is a
/// `_MarkedComponent`, one in fifty is a `_RareComponent`, and the remaining
/// four in five are `_PlainComponent`s.
List<Component> _mixedComponents(int amount) {
  return List.generate(amount, (i) {
    if (i % 50 == 0) {
      return _RareComponent();
    }
    return i % 5 == 0 ? _MarkedComponent() : _PlainComponent();
  });
}

/// Which query caches are registered on the container that is churned by
/// [TypeQueryChurnBenchmark].
enum QueryRegistrations {
  none('no registered queries, whereType scan'),
  marked('1 registered query (matches 1 in 5)'),
  markedAndRare('2 registered queries (second matches 1 in 50)'),
  markedAndPlain('2 registered queries (second matches 4 in 5)');

  const QueryRegistrations(this.label);

  final String label;

  /// Whether `_MarkedComponent` has a cache, and reads can go through
  /// `query<T>()` instead of a `whereType<T>()` scan.
  bool get isMarkedRegistered => this != none;

  void applyTo(ComponentList children) {
    if (this != none) {
      children.register<_MarkedComponent>();
    }
    if (this == markedAndRare) {
      children.register<_RareComponent>();
    }
    if (this == markedAndPlain) {
      children.register<_PlainComponent>();
    }
  }
}

/// Measures the per-type query caches of the children container
/// (`children.register<T>()` / `children.query<T>()`), which Flame uses
/// internally for hitboxes (`GestureHitboxes`), post-processing
/// (`CameraComponent`), and layout (`LinearLayoutComponent`).
///
/// Every add and remove has to update all registered caches, so this benchmark
/// churns a mixed-type population while reading one query per tick. A
/// children-container replacement must keep both the cache-maintenance and the
/// query-read cost at least this fast.
///
/// The [registrations] variants separate the two things that could drive the
/// maintenance cost:
///  - [QueryRegistrations.marked] against [QueryRegistrations.markedAndRare]:
///    one more cache, but one that almost never matches, so only the per-add
///    and per-remove type check is added;
///  - [QueryRegistrations.markedAndRare] against
///    [QueryRegistrations.markedAndPlain]: the same number of caches, but the
///    second one now holds most of the container, so the cost of maintaining a
///    cache entry itself dominates;
///  - [QueryRegistrations.none] against [QueryRegistrations.marked]: the whole
///    trade, cache maintenance on every structural change against a
///    `whereType` scan on every read. The no-cache variant reads through
///    `whereType<T>()`, which falls back to a linear scan of the backing array
///    when no cache exists for the type.
class TypeQueryChurnBenchmark extends AsyncBenchmarkBase {
  static const _amountStatic = 1000;
  static const _batchSize = 50;
  static const _liveBatches = 5;
  static const _amountTicks = 60;

  final QueryRegistrations registrations;

  late final FlameGame _game;
  final Queue<List<Component>> _batches = Queue();

  TypeQueryChurnBenchmark({
    this.registrations = QueryRegistrations.markedAndPlain,
  }) : super('Type-query churn (${registrations.label})');

  static Future<void> main() async {
    for (final registrations in QueryRegistrations.values) {
      await TypeQueryChurnBenchmark(registrations: registrations).report();
    }
  }

  @override
  Future<void> setup() async {
    _game = FlameGame();
    await mountGame(_game);
    registrations.applyTo(_game.world.children);
    _game.world.addAll(_mixedComponents(_amountStatic));
    for (var i = 0; i < _liveBatches; i++) {
      final batch = _mixedComponents(_batchSize);
      _batches.addLast(batch);
      _game.world.addAll(batch);
    }
    await _game.ready();
  }

  @override
  Future<void> run() async {
    final children = _game.world.children;
    final isMarkedRegistered = registrations.isMarkedRegistered;
    var visited = 0;
    for (var i = 0; i < _amountTicks; i++) {
      _game.world.removeAll(_batches.removeFirst());
      final batch = _mixedComponents(_batchSize);
      _batches.addLast(batch);
      _game.world.addAll(batch);
      final marked = isMarkedRegistered
          ? children.query<_MarkedComponent>()
          : children.whereType<_MarkedComponent>();
      for (final component in marked) {
        visited += component.marker;
      }
      _game.update(_dt);
    }
    assert(visited > 0);
  }
}

/// Measures the read side of the query caches in isolation: [_amountReads]
/// repeated reads of every `_MarkedComponent` in a static container of
/// [amountChildren] children, one fifth of which match.
///
/// The [cached] variant registers the type and reads through `query<T>()`,
/// which returns a maintained list of exactly the matching children. The
/// uncached variant reads through `whereType<T>()`, which, without a cache for
/// the type, scans the whole backing array.
///
/// The gap between the two is what a cache buys on the read side, and it is
/// the number to weigh against the maintenance cost measured by
/// [TypeQueryChurnBenchmark]. It is measured at both a large container size
/// (where the scan has to skip many non-matching children) and at a typical
/// per-component size (where a query such as `GestureHitboxes.hitboxes` runs
/// over a handful of children).
class TypeQueryReadBenchmark extends AsyncBenchmarkBase {
  static const _amountReads = 500;

  final int amountChildren;
  final bool cached;

  late final FlameGame _game;
  late final Component _parent;

  TypeQueryReadBenchmark({required this.amountChildren, required this.cached})
    : super(
        'Type-query read ($amountChildren children, '
        '${cached ? 'cached query' : 'whereType scan'})',
      );

  static Future<void> main() async {
    for (final amountChildren in [1000, 16]) {
      for (final cached in [false, true]) {
        await TypeQueryReadBenchmark(
          amountChildren: amountChildren,
          cached: cached,
        ).report();
      }
    }
  }

  @override
  Future<void> setup() async {
    _game = FlameGame();
    await mountGame(_game);
    _parent = Component();
    _game.world.add(_parent);
    await _game.ready();
    if (cached) {
      _parent.children.register<_MarkedComponent>();
    }
    _parent.addAll(_mixedComponents(amountChildren));
    await _game.ready();
  }

  @override
  Future<void> run() async {
    final children = _parent.children;
    var visited = 0;
    for (var i = 0; i < _amountReads; i++) {
      final marked = cached
          ? children.query<_MarkedComponent>()
          : children.whereType<_MarkedComponent>();
      for (final component in marked) {
        visited += component.marker;
      }
    }
    assert(visited > 0);
  }
}

class _MarkedComponent extends Component {
  final int marker = 1;
}

class _PlainComponent extends Component {}

class _RareComponent extends Component {}

Future<void> main() async {
  await TypeQueryChurnBenchmark.main();
  await TypeQueryReadBenchmark.main();
}
