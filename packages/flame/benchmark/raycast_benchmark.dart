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

/// The number of different rotations of the scene when it rotates.
const _phases = 8;

/// The rotation in radians that the components are turned by in each phase.
const _phaseAngle = 0.05;

/// Benchmarks [CollisionDetection.raycast] in a scene of [count] hitboxes of
/// the given [kind], with the old code path or the one that visits the
/// hitboxes from the nearest to the farthest, depending on [nearestFirst].
/// Each run casts the same [_raysPerRun] rays.
///
/// If [rotate] is true, every run starts by turning all of the components to
/// the next of [_phases] rotations, so the bounding boxes and vertices of the
/// hitboxes are computed again, like in a game where things rotate. The cost
/// of that is in the time of both code paths. The rotations repeat, so that
/// both code paths find the same hits in the same phase of the scene.
class RaycastBenchmark extends AsyncBenchmarkBase {
  RaycastBenchmark({
    required this.kind,
    required this.count,
    required this.nearestFirst,
    this.rotate = false,
  }) : super('Raycast ${kind.name} x$count');

  final HitboxKind kind;
  final int count;
  final bool nearestFirst;
  final bool rotate;

  late final _RaycastGame _game;
  late final List<Ray2> _rays;
  late final List<PositionComponent> _components;
  late final List<double> _baseAngles;
  final _result = RaycastResult<ShapeHitbox>();
  var _phase = 0;
  final _hitsByPhase = List<int?>.filled(_phases, null);

  @override
  Future<void> setup() async {
    // The same scene and rays for both code paths.
    final random = Random(69420);
    _game = _RaycastGame();
    await mountGame(_game, size: Vector2(_worldWidth, _worldHeight));
    _components = [for (var i = 0; i < count; i++) _component(random, i)];
    _baseAngles = [for (final component in _components) component.angle];
    _game.world.addAll(_components);
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
    if (rotate) {
      _phase = (_phase + 1) % _phases;
      for (var i = 0; i < _components.length; i++) {
        _components[i].angle = _baseAngles[i] + _phase * _phaseAngle;
      }
    }
    var hits = 0;
    for (final ray in _rays) {
      if (detection.raycast(ray, out: _result) != null) {
        hits++;
      }
    }
    _hitsByPhase[_phase] = hits;
  }

  /// The number of rays that hit something in each phase of the scene, to keep
  /// the work from being optimized away and to check that both code paths
  /// agree. It is null for the phases that did not run.
  List<int?> get hitsByPhase => _hitsByPhase;

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
    'kind      hitboxes  rotate  old [us/ray]  new [us/ray]  speedup  hits',
  );
  for (final kind in HitboxKind.values) {
    for (final count in counts) {
      for (final rotate in [false, true]) {
        final old = RaycastBenchmark(
          kind: kind,
          count: count,
          nearestFirst: false,
          rotate: rotate,
        );
        final oldMicros = await old.measure();
        final nearest = RaycastBenchmark(
          kind: kind,
          count: count,
          nearestFirst: true,
          rotate: rotate,
        );
        final newMicros = await nearest.measure();
        final oldPerRay = oldMicros / _raysPerRun;
        final newPerRay = newMicros / _raysPerRun;
        // Compare the phases that both code paths ran.
        var phasesCompared = 0;
        var same = true;
        for (var phase = 0; phase < _phases; phase++) {
          final a = old.hitsByPhase[phase];
          final b = nearest.hitsByPhase[phase];
          if (a != null && b != null) {
            phasesCompared++;
            same &= a == b;
          }
        }
        // ignore: avoid_print
        print(
          '${kind.name.padRight(10)}${'$count'.padRight(10)}'
          '${(rotate ? 'yes' : 'no').padRight(8)}'
          '${oldPerRay.toStringAsFixed(2).padRight(14)}'
          '${newPerRay.toStringAsFixed(2).padRight(14)}'
          '${'${(oldPerRay / newPerRay).toStringAsFixed(2)}x'.padRight(9)}'
          '${same && phasesCompared > 0 ? 'same' : 'DIFFERENT'} '
          '($phasesCompared phases)',
        );
      }
    }
  }
}
