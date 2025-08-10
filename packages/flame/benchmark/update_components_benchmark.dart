import 'dart:math';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

const _amountComponents = 1000;
const _amountTicks = 2000;
const _amountInputs = 500;
const _amountChildren = 10;

class UpdateComponentsBenchmark extends AsyncBenchmarkBase {
  final Random random;

  late final FlameGame _game;
  late final List<_BenchmarkComponent> _components;
  late final List<double> _dts;
  late final Set<int> _inputTicks;

  UpdateComponentsBenchmark(this.random)
    : super('Updating Components Benchmark');

  static Future<void> main() async {
    final r = Random(69420);
    await UpdateComponentsBenchmark(r).report();
  }

  @override
  Future<void> setup() async {
    _game = FlameGame();
    await _game.addAll(
      List.generate(_amountComponents, _BenchmarkComponent.new),
    );

    await _game.ready();

    _components = _game.children.whereType<_BenchmarkComponent>().toList(
      growable: false,
    );

    _dts = List.generate(_amountTicks, (_) => random.nextDouble());
    _inputTicks = List.generate(
      _amountInputs,
      (_) => random.nextInt(_amountTicks),
    ).toSet();
  }

  @override
  Future<void> run() async {
    for (final (index, dt) in _dts.indexed) {
      if (_inputTicks.contains(index)) {
        _components[random.nextInt(_amountComponents)].input(
          xDirection: random.nextInt(3) - 1,
          doJump: random.nextBool(),
        );
      }
      _game.update(dt);
    }
  }
}

class _BenchmarkComponent extends PositionComponent {
  static const _groundY = -20.0;

  final int id;
  final Vector2 velocity = Vector2.zero();

  _BenchmarkComponent(this.id);

  @override
  Future<void> onLoad() async {
    for (var i = 0; i < _amountChildren; i++) {
      await add(PositionComponent(position: Vector2(i * 2, 0)));
    }
  }

  void input({
    required int xDirection,
    required bool doJump,
  }) {
    // move x
    velocity.x = xDirection * 100;

    // jump
    if (position.y == _groundY) {
      velocity.y -= 100;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.add(velocity * dt);
    velocity.add(Vector2(0, 10 * dt));

    if (position.y > _groundY) {
      position.y = _groundY;
      velocity.setValues(0, 0);
    }
  }

  @override
  String toString() => '[Component $id]';
}
