import 'dart:math';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'common.dart';

const _dt = 1.0 / 60;
const _worldWidth = 800.0;
const _worldHeight = 600.0;

/// The traversal benchmarks in `children_traversal_benchmark.dart` use no-op
/// components, so they measure the framework overhead in isolation. These
/// benchmarks reuse the same wide and nested tree shapes but give every
/// component a realistic [Component.update] body, to show how much of a real
/// game's update pass that overhead actually accounts for.
///
/// Two workloads are measured, both written the way a typical game would:
/// - light: bullet or particle style movement, integrating a velocity and
///   bouncing off the world bounds. This is about the cheapest update a game
///   component can reasonably have.
/// - heavy: enemy AI style steering: scan a few dozen moving targets for the
///   nearest one, steer towards it with clamped acceleration, face the
///   movement direction, and tick a cooldown timer. This is representative of
///   a logic-heavy entity.
///
/// Neither workload allocates per tick, so the measured time is the update
/// logic itself rather than garbage collection of temporary vectors.
///
/// The tick counts are chosen so that each run stays well under 100ms, so
/// the light and heavy rows are not directly comparable to each other, only
/// to their own no-op counterpart in the traversal suite and across engine
/// versions.
abstract class _WorkloadBenchmark extends AsyncBenchmarkBase {
  static const _amountTargets = 32;

  _WorkloadBenchmark(
    super.name, {
    required this.ticks,
    required this.heavy,
  });

  final int ticks;
  final bool heavy;
  final Random _random = Random(69420);
  late final FlameGame _game;
  late final List<Vector2> _targets;
  double _time = 0;

  void buildTree(World world);

  Component createComponent() {
    final position = Vector2(
      _random.nextDouble() * _worldWidth,
      _random.nextDouble() * _worldHeight,
    );
    final velocity = Vector2(
      _random.nextDouble() * 200 - 100,
      _random.nextDouble() * 200 - 100,
    );
    return heavy
        ? _HeavyComponent(
            position: position,
            velocity: velocity,
            targets: _targets,
            cooldown: _random.nextDouble(),
          )
        : _LightComponent(position: position, velocity: velocity);
  }

  @override
  Future<void> setup() async {
    _targets = List.generate(_amountTargets, (_) => Vector2.zero());
    _moveTargets();
    _game = FlameGame();
    await mountGame(_game);
    buildTree(_game.world);
    await _game.ready();
  }

  void _moveTargets() {
    for (var i = 0; i < _targets.length; i++) {
      final phase = _time + i * (2 * pi / _targets.length);
      _targets[i].setValues(
        _worldWidth / 2 + cos(phase) * _worldWidth / 3,
        _worldHeight / 2 + sin(phase) * _worldHeight / 3,
      );
    }
  }

  @override
  Future<void> run() async {
    for (var i = 0; i < ticks; i++) {
      _time += _dt;
      _moveTargets();
      _game.update(_dt);
    }
  }
}

/// 10k components in a single children container.
class WideTreeWorkloadBenchmark extends _WorkloadBenchmark {
  static const _amountChildren = 10000;

  WideTreeWorkloadBenchmark({required super.heavy})
    : super(
        'Update wide tree (10k x 1), ${heavy ? 'heavy' : 'light'} logic',
        ticks: heavy ? 10 : 50,
      );

  static Future<void> main() async {
    await WideTreeWorkloadBenchmark(heavy: false).report();
    await WideTreeWorkloadBenchmark(heavy: true).report();
  }

  @override
  void buildTree(World world) {
    world.addAll(List.generate(_amountChildren, (_) => createComponent()));
  }
}

/// 1k parents with 10 children each: many small children containers.
class NestedTreeWorkloadBenchmark extends _WorkloadBenchmark {
  static const _amountParents = 1000;
  static const _amountChildren = 10;

  NestedTreeWorkloadBenchmark({required super.heavy})
    : super(
        'Update nested tree (1k x 10), ${heavy ? 'heavy' : 'light'} logic',
        ticks: heavy ? 9 : 45,
      );

  static Future<void> main() async {
    await NestedTreeWorkloadBenchmark(heavy: false).report();
    await NestedTreeWorkloadBenchmark(heavy: true).report();
  }

  @override
  void buildTree(World world) {
    world.addAll(
      List.generate(_amountParents, (_) {
        final parent = createComponent();
        parent.addAll(
          List.generate(_amountChildren, (_) => createComponent()),
        );
        return parent;
      }),
    );
  }
}

class _LightComponent extends PositionComponent {
  final Vector2 velocity;

  _LightComponent({required super.position, required this.velocity});

  @override
  void update(double dt) {
    position.addScaled(velocity, dt);
    if (position.x < 0 || position.x > _worldWidth) {
      velocity.x = -velocity.x;
    }
    if (position.y < 0 || position.y > _worldHeight) {
      velocity.y = -velocity.y;
    }
  }
}

class _HeavyComponent extends PositionComponent {
  static const _maxSpeed = 120.0;
  static const _acceleration = 300.0;
  static const _cooldownDuration = 1.5;

  final Vector2 velocity;
  final List<Vector2> targets;
  final Vector2 _steering = Vector2.zero();
  double cooldown;
  int shotsFired = 0;

  _HeavyComponent({
    required super.position,
    required this.velocity,
    required this.targets,
    required this.cooldown,
  });

  @override
  void update(double dt) {
    var nearest = targets.first;
    var nearestDistance = double.infinity;
    for (final target in targets) {
      final distance = position.distanceToSquared(target);
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearest = target;
      }
    }

    _steering
      ..setFrom(nearest)
      ..sub(position);
    final steeringLength = _steering.length;
    if (steeringLength > 0) {
      _steering.scale(_acceleration * dt / steeringLength);
    }
    velocity.add(_steering);
    final speed = velocity.length;
    if (speed > _maxSpeed) {
      velocity.scale(_maxSpeed / speed);
    }

    position.addScaled(velocity, dt);
    angle = atan2(velocity.y, velocity.x);

    cooldown -= dt;
    if (cooldown <= 0) {
      cooldown += _cooldownDuration;
      if (nearestDistance < 200 * 200) {
        shotsFired++;
      }
    }
  }
}

Future<void> main() async {
  await WideTreeWorkloadBenchmark.main();
  await NestedTreeWorkloadBenchmark.main();
}
