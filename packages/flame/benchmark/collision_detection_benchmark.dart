import 'dart:math';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

const _amountComponents = 100;
const _amountTicks = 500;

/// Benchmarks collision detection with simple flat hitboxes (no hierarchy).
/// All components are direct children of the game world.
class FlatCollisionBenchmark extends AsyncBenchmarkBase {
  final Random random;

  late final FlameGame _game;
  late final List<_MovingBlock> _blocks;

  FlatCollisionBenchmark(this.random) : super('Flat collision detection');

  static Future<void> main() async {
    final r = Random(69420);
    await FlatCollisionBenchmark(r).report();
  }

  @override
  Future<void> setup() async {
    _game = _CollisionGame();
    _game.onGameResize(Vector2.all(800));

    _blocks = List.generate(
      _amountComponents,
      (_) => _MovingBlock(
        position: Vector2.random(random) * 700,
        size: Vector2.random(random) * 50 + Vector2.all(10),
        velocity: Vector2(
          random.nextInt(200) * (random.nextBool() ? 1.0 : -1.0),
          random.nextInt(200) * (random.nextBool() ? 1.0 : -1.0),
        ),
      ),
    );

    await _game.addAll(_blocks);
    await _game.ready();
  }

  @override
  Future<void> run() async {
    for (var i = 0; i < _amountTicks; i++) {
      _game.update(1 / 60);
    }
  }
}

/// Benchmarks collision detection with nested hierarchies where children have
/// hitboxes and parents have non-uniform scale/rotation. This exercises the
/// globalVertices() and AABB computation codepaths.
class NestedCollisionBenchmark extends AsyncBenchmarkBase {
  final Random random;

  late final FlameGame _game;

  NestedCollisionBenchmark(this.random)
    : super('Nested hierarchy collision detection');

  static Future<void> main() async {
    final r = Random(69420);
    await NestedCollisionBenchmark(r).report();
  }

  @override
  Future<void> setup() async {
    _game = _CollisionGame();
    _game.onGameResize(Vector2.all(800));

    final components = <Component>[];
    for (var i = 0; i < _amountComponents; i++) {
      final parent = PositionComponent(
        position: Vector2.random(random) * 700,
        size: Vector2.all(40),
        scale: Vector2(
          1 + random.nextDouble(),
          1 + random.nextDouble(),
        ),
        angle: random.nextDouble() * 2 * pi,
      );
      final child = _MovingBlock(
        position: Vector2.zero(),
        size: Vector2.all(20),
        velocity: Vector2(
          random.nextInt(100) * (random.nextBool() ? 1.0 : -1.0),
          random.nextInt(100) * (random.nextBool() ? 1.0 : -1.0),
        ),
      );
      parent.add(child);
      components.add(parent);
    }

    await _game.addAll(components);
    await _game.ready();
  }

  @override
  Future<void> run() async {
    for (var i = 0; i < _amountTicks; i++) {
      _game.update(1 / 60);
    }
  }
}

/// Benchmarks globalVertices() calls directly for polygon components in
/// hierarchies with non-uniform scale and rotation.
class GlobalVerticesBenchmark extends AsyncBenchmarkBase {
  final Random random;

  late final FlameGame _game;
  late final List<RectangleHitbox> _hitboxes;

  GlobalVerticesBenchmark(this.random) : super('globalVertices() computation');

  static Future<void> main() async {
    final r = Random(69420);
    await GlobalVerticesBenchmark(r).report();
  }

  @override
  Future<void> setup() async {
    _game = FlameGame();
    _game.onGameResize(Vector2.all(800));

    _hitboxes = [];
    for (var i = 0; i < _amountComponents; i++) {
      final parent = PositionComponent(
        position: Vector2.random(random) * 700,
        size: Vector2.all(40),
        scale: Vector2(
          1 + random.nextDouble(),
          1 + random.nextDouble(),
        ),
        angle: random.nextDouble() * 2 * pi,
      );
      final child = PositionComponent(
        position: Vector2.zero(),
        size: Vector2.all(20),
        angle: random.nextDouble() * 2 * pi,
      );
      final hitbox = RectangleHitbox();
      child.add(hitbox);
      parent.add(child);
      _game.add(parent);
      _hitboxes.add(hitbox);
    }

    await _game.ready();
  }

  @override
  Future<void> run() async {
    // Invalidate caches by moving parents slightly, then recompute.
    for (final hitbox in _hitboxes) {
      final parent = hitbox.parent!.parent! as PositionComponent;
      parent.angle += 0.01;
    }
    for (final hitbox in _hitboxes) {
      hitbox.globalVertices();
    }
  }
}

class _CollisionGame extends FlameGame with HasCollisionDetection {}

class _MovingBlock extends PositionComponent with CollisionCallbacks {
  final Vector2 velocity;

  _MovingBlock({
    required super.position,
    required super.size,
    required this.velocity,
  }) {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (position.length2 > 100000) {
      velocity.negate();
    }
    position.add(velocity * dt);
  }
}

Future<void> main() async {
  final r1 = Random(69420);
  await FlatCollisionBenchmark(r1).report();

  final r2 = Random(69420);
  await NestedCollisionBenchmark(r2).report();

  final r3 = Random(69420);
  await GlobalVerticesBenchmark(r3).report();
}
