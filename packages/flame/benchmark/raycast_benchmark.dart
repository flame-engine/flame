import 'dart:math';
import 'dart:ui';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';

import 'common.dart';

const _raysPerRun = 200;
const _worldWidth = 800.0;
const _worldHeight = 600.0;

/// The kinds of hitboxes of the scene, from the cheapest to the most
/// expensive to intersect with a ray.
enum HitboxKind { simple, polygons, paths, mixed }

/// Benchmarks [CollisionDetection.raycast] in a static scene of [count]
/// hitboxes of the given [kind], with the old code path or the one that
/// visits the hitboxes from the nearest to the farthest, depending on
/// [nearestFirst]. Each run casts the same [_raysPerRun] rays.
class RaycastBenchmark extends AsyncBenchmarkBase {
  RaycastBenchmark({
    required this.kind,
    required this.count,
    required this.nearestFirst,
  }) : super('Raycast ${kind.name} x$count');

  final HitboxKind kind;
  final int count;
  final bool nearestFirst;

  late final _RaycastGame _game;
  late final List<Ray2> _rays;
  final _result = RaycastResult<ShapeHitbox>();
  var _hits = 0;

  @override
  Future<void> setup() async {
    // The same scene and rays for both code paths.
    final random = Random(69420);
    _game = _RaycastGame();
    await mountGame(_game, size: Vector2(_worldWidth, _worldHeight));
    _game.world.addAll([
      for (var i = 0; i < count; i++) _component(random, i),
    ]);
    await _game.ready();
    _game.update(0);
    _rays = [
      for (var i = 0; i < _raysPerRun; i++)
        Ray2(
          origin: Vector2(
            random.nextDouble() * _worldWidth,
            random.nextDouble() * _worldHeight,
          ),
          direction: (Vector2.random(random) - Vector2.all(0.5))..normalize(),
        ),
    ];
    StandardCollisionDetection.nearestFirstRaycast = nearestFirst;
  }

  @override
  Future<void> teardown() async {
    StandardCollisionDetection.nearestFirstRaycast = false;
  }

  @override
  Future<void> run() async {
    final detection = _game.world.collisionDetection;
    _hits = 0;
    for (final ray in _rays) {
      if (detection.raycast(ray, out: _result) != null) {
        _hits++;
      }
    }
  }

  /// The number of rays that hit something in the last run, to keep the work
  /// from being optimized away and to check that both code paths agree.
  int get hits => _hits;

  PositionComponent _component(Random random, int index) {
    final size = 30 + random.nextDouble() * 50;
    final hitbox = switch (kind) {
      HitboxKind.simple => _simple(random, index, size),
      HitboxKind.polygons => _polygon(size),
      HitboxKind.paths => _path(size),
      HitboxKind.mixed => switch (index % 4) {
        0 || 1 => _simple(random, index, size),
        2 => _polygon(size),
        _ => _path(size),
      },
    };
    return PositionComponent(
      position: Vector2(
        random.nextDouble() * _worldWidth,
        random.nextDouble() * _worldHeight,
      ),
      angle: random.nextDouble() * 2 * pi,
      size: Vector2.all(size),
      anchor: Anchor.center,
      children: [hitbox],
    );
  }

  ShapeHitbox _simple(Random random, int index, double size) {
    return index.isEven
        ? RectangleHitbox(
            size: Vector2.all(size),
            collisionType: CollisionType.inactive,
          )
        : CircleHitbox(
            radius: size / 2,
            collisionType: CollisionType.inactive,
          );
  }

  ShapeHitbox _polygon(double size) {
    return PolygonHitbox(
      _starVertices(size),
      collisionType: CollisionType.inactive,
    );
  }

  ShapeHitbox _path(double size) {
    final vertices = _starVertices(size);
    final path = Path()..moveTo(vertices.first.x, vertices.first.y);
    for (final vertex in vertices.skip(1)) {
      path.lineTo(vertex.x, vertex.y);
    }
    return PathHitbox(
      path: path..close(),
      collisionType: CollisionType.inactive,
    );
  }

  /// The vertices of a concave star with 24 vertices.
  List<Vector2> _starVertices(double size) {
    return [
      for (var i = 0; i < 24; i++)
        Vector2(
          size / 2 + (i.isEven ? size / 2 : size / 5) * cos(i * pi / 12),
          size / 2 + (i.isEven ? size / 2 : size / 5) * sin(i * pi / 12),
        ),
    ];
  }
}

class _RaycastGame extends FlameGame<_RaycastWorld> {
  _RaycastGame() : super(world: _RaycastWorld());
}

class _RaycastWorld extends World with HasCollisionDetection {}

/// Runs the benchmark for the old and the new code path in all the cases, and
/// prints a table with the time per ray and the speedup.
Future<void> main() async {
  const counts = [100, 200, 500];
  // ignore: avoid_print
  print('Raycast: old code path vs nearest first ($_raysPerRun rays per run)');
  // ignore: avoid_print
  print(
    'kind      hitboxes  old [us/ray]  new [us/ray]  speedup  hits (old/new)',
  );
  for (final kind in HitboxKind.values) {
    for (final count in counts) {
      final old = RaycastBenchmark(
        kind: kind,
        count: count,
        nearestFirst: false,
      );
      final oldMicros = await old.measure();
      final nearest = RaycastBenchmark(
        kind: kind,
        count: count,
        nearestFirst: true,
      );
      final newMicros = await nearest.measure();
      final oldPerRay = oldMicros / _raysPerRun;
      final newPerRay = newMicros / _raysPerRun;
      // ignore: avoid_print
      print(
        '${kind.name.padRight(10)}${'$count'.padRight(10)}'
        '${oldPerRay.toStringAsFixed(2).padRight(14)}'
        '${newPerRay.toStringAsFixed(2).padRight(14)}'
        '${'${(oldPerRay / newPerRay).toStringAsFixed(2)}x'.padRight(9)}'
        '${old.hits == nearest.hits ? 'same' : 'DIFFERENT'} '
        '(${old.hits}/${nearest.hits})',
      );
    }
  }
}
