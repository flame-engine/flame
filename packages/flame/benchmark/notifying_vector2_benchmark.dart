import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

const _amountComponents = 10000;
const _dt = 1.0 / 60;

/// Measures the cost of mutating the notifying vectors of real
/// [PositionComponent]s, which is the path taken by `position.add(...)`,
/// `position.x = ...`, and `size.setValues(...)` in every game.
///
/// Each vector has the listener that the owning [Transform2D] or
/// [PositionComponent] registers, and the size benchmark adds one extra
/// listener to exercise the multi-listener path.
abstract class _NotifyingVector2Benchmark extends BenchmarkBase {
  late final List<PositionComponent> _components;

  _NotifyingVector2Benchmark(super.name);

  @override
  void setup() {
    _components = List.generate(
      _amountComponents,
      (i) => PositionComponent(
        position: Vector2(i.toDouble(), -i.toDouble()),
        size: Vector2.all(10),
      ),
      growable: false,
    );
  }

  @override
  void exercise() => run();
}

class PositionAddScaledBenchmark extends _NotifyingVector2Benchmark {
  final _velocity = Vector2(30, -20);

  PositionAddScaledBenchmark() : super('NotifyingVector2 addScaled');

  static Future<void> main() async {
    PositionAddScaledBenchmark().report();
  }

  @override
  void run() {
    for (var i = 0; i < _amountComponents; i++) {
      _components[i].position.addScaled(_velocity, _dt);
    }
  }
}

class PositionAddExpressionBenchmark extends _NotifyingVector2Benchmark {
  final _velocity = Vector2(30, -20);

  PositionAddExpressionBenchmark()
    : super('NotifyingVector2 add(velocity * dt), allocating');

  static Future<void> main() async {
    PositionAddExpressionBenchmark().report();
  }

  @override
  void run() {
    for (var i = 0; i < _amountComponents; i++) {
      _components[i].position.add(_velocity * _dt);
    }
  }
}

class PositionValueAddBenchmark extends _NotifyingVector2Benchmark {
  final _velocity = VectorValue(30, -20);

  PositionValueAddBenchmark()
    : super('NotifyingVector2 value += velocity * dt, allocation-free');

  static Future<void> main() async {
    PositionValueAddBenchmark().report();
  }

  @override
  void run() {
    for (var i = 0; i < _amountComponents; i++) {
      _components[i].position.value += _velocity * _dt;
    }
  }
}

class PositionValueExpressionBenchmark extends _NotifyingVector2Benchmark {
  final _velocity = VectorValue(30, -20);
  final _offset = VectorValue(3, 4);

  PositionValueExpressionBenchmark()
    : super('NotifyingVector2 value = size.value / 2 + offset + velocity * dt');

  static Future<void> main() async {
    PositionValueExpressionBenchmark().report();
  }

  @override
  void run() {
    for (var i = 0; i < _amountComponents; i++) {
      final component = _components[i];
      component.position.value =
          component.size.value / 2 + _offset + _velocity * _dt;
    }
  }
}

class PositionChainedExpressionBenchmark extends _NotifyingVector2Benchmark {
  final _velocity = Vector2(30, -20);
  final _offset = Vector2(3, 4);

  PositionChainedExpressionBenchmark()
    : super('NotifyingVector2 setFrom((size / 2)..add(offset)..addScaled())');

  static Future<void> main() async {
    PositionChainedExpressionBenchmark().report();
  }

  @override
  void run() {
    for (var i = 0; i < _amountComponents; i++) {
      final component = _components[i];
      component.position.setFrom(
        (component.size / 2)
          ..add(_offset)
          ..addScaled(_velocity, _dt),
      );
    }
  }
}

class PositionSetXBenchmark extends _NotifyingVector2Benchmark {
  PositionSetXBenchmark() : super('NotifyingVector2 set x');

  static Future<void> main() async {
    PositionSetXBenchmark().report();
  }

  @override
  void run() {
    for (var i = 0; i < _amountComponents; i++) {
      _components[i].position.x = i.toDouble();
    }
  }
}

class SizeSetValuesBenchmark extends _NotifyingVector2Benchmark {
  int _extraListenerCalls = 0;

  SizeSetValuesBenchmark() : super('NotifyingVector2 setValues (2 listeners)');

  static Future<void> main() async {
    SizeSetValuesBenchmark().report();
  }

  @override
  void setup() {
    super.setup();
    for (final component in _components) {
      component.size.addListener(() => _extraListenerCalls++);
    }
  }

  @override
  void run() {
    for (var i = 0; i < _amountComponents; i++) {
      _components[i].size.setValues(10, i.toDouble());
    }
  }
}

Future<void> main() async {
  await PositionAddScaledBenchmark.main();
  await PositionAddExpressionBenchmark.main();
  await PositionValueAddBenchmark.main();
  await PositionChainedExpressionBenchmark.main();
  await PositionValueExpressionBenchmark.main();
  await PositionSetXBenchmark.main();
  await SizeSetValuesBenchmark.main();
}
