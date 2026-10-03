// ignore_for_file: use_primary_constructors, empty_container_bodies
// ignore_for_file: unnecessary_const_in_enum_constructor

import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';

import 'common.dart';

/// The number of rays that are cast against a scene in each run.
const raycastRaysPerRun = 200;

const _worldWidth = 800.0;
const _worldHeight = 600.0;

/// The kinds of hitboxes of a scene.
enum HitboxKind {
  /// The cheapest to intersect with a ray: rectangles and circles.
  simple,

  /// Concave polygons.
  polygons,

  /// Concave paths, the most expensive.
  paths,

  /// All of the above.
  mixed,

  /// Rectangles that do not allocate when a ray is tested against them, and
  /// are never hit, so that any allocation is of the code that casts the rays.
  stubMiss,

  /// Like [stubMiss], but each hitbox is hit where the ray enters its box, the
  /// nearest that a hit can be.
  stubHit,

  /// Circles placed so that the rays cross their boxes but miss them, which
  /// is the cheapest miss of a built-in hitbox. The rays and the circles do
  /// not depend on the [RaycastScene].
  circlesMiss;

  /// The kinds that are real shapes.
  static const shapes = [simple, polygons, paths, mixed];
}

/// The sizes of the hitboxes of a scene.
enum RaycastScene {
  /// Small hitboxes, so that a ray crosses the boxes of a few of them.
  spread(30, 80),

  /// Hitboxes as big as most of the world, so that a ray crosses the boxes of
  /// many of them, and, with the concave ones, hits few of them.
  dense(300, 500);

  const RaycastScene(this.minSize, this.maxSize);

  final double minSize;
  final double maxSize;
}

class RaycastGame extends FlameGame<RaycastWorld> {
  RaycastGame() : super(world: RaycastWorld());
}

class RaycastWorld extends World with HasCollisionDetection {}

/// A scene of hitboxes in a [RaycastGame], and rays to cast against it. The
/// scene and the rays only depend on the arguments, so the same scene can be
/// built to compare ways to cast rays.
class RaycastScenery {
  RaycastScenery._(this.game, this.components, this.rays);

  final RaycastGame game;
  final List<PositionComponent> components;
  final List<Ray2> rays;

  CollisionDetection<ShapeHitbox, Broadphase<ShapeHitbox>> get detection =>
      game.world.collisionDetection;

  static Future<RaycastScenery> create({
    required HitboxKind kind,
    required int count,
    RaycastScene scene = RaycastScene.spread,
  }) async {
    final random = Random(69420);
    final game = RaycastGame();
    await mountGame(game, size: Vector2(_worldWidth, _worldHeight));
    if (kind == HitboxKind.circlesMiss) {
      return await _circlesMiss(game, count);
    }
    final components = [
      for (var i = 0; i < count; i++) _component(random, i, kind, scene),
    ];
    game.world.addAll(components);
    await game.ready();
    game.update(0);
    final rays = [
      for (var i = 0; i < raycastRaysPerRun; i++)
        Ray2(
          origin: Vector2(
            random.nextDouble() * _worldWidth,
            random.nextDouble() * _worldHeight,
          ),
          direction: (Vector2.random(random) - Vector2.all(0.5))..normalize(),
        ),
    ];
    return RaycastScenery._(game, components, rays);
  }

  /// The distance between the parallel lines that the rays of [_circlesMiss]
  /// follow.
  static const _lineSpacing = 40.0;

  /// The radius of the circles of [_circlesMiss], so that the lines on both
  /// sides of a circle, at half of [_lineSpacing] from its center, cross its
  /// box, which they do up to the radius times the square root of 2, and miss
  /// it.
  static const _missRadius = 0.42 * _lineSpacing;

  /// Rays that follow 4 parallel diagonal lines, and [count] circles in the 3
  /// gaps between the lines, so that each ray crosses the boxes of the circles
  /// in the gaps next to its line, and hits none of them.
  static Future<RaycastScenery> _circlesMiss(
    RaycastGame game,
    int count,
  ) async {
    final along = Vector2(1, 1)..normalize();
    final across = Vector2(-1, 1)..normalize();
    final start = Vector2(100, 50);
    Vector2 point(double u, double v) =>
        start + along.scaled(u) + across.scaled(v);
    const gaps = 3;
    final perGap = (count / gaps).ceil();
    final spacing = 600 / perGap;
    final components = [
      for (var i = 0; i < count; i++)
        PositionComponent(
          position: point(
            50 + (i ~/ gaps) * spacing,
            (i % gaps + 0.5) * _lineSpacing,
          ),
          size: Vector2.all(2 * _missRadius),
          anchor: Anchor.center,
          children: [
            CircleHitbox(
              radius: _missRadius,
              collisionType: CollisionType.inactive,
            ),
          ],
        ),
    ];
    game.world.addAll(components);
    await game.ready();
    game.update(0);
    final rays = [
      for (var i = 0; i < raycastRaysPerRun; i++)
        Ray2(
          origin: point(0, (i % (gaps + 1)) * _lineSpacing),
          direction: along.clone(),
        ),
    ];
    return RaycastScenery._(game, components, rays);
  }

  static PositionComponent _component(
    Random random,
    int index,
    HitboxKind kind,
    RaycastScene scene,
  ) {
    final size =
        scene.minSize + random.nextDouble() * (scene.maxSize - scene.minSize);
    final hitbox = switch (kind) {
      HitboxKind.simple => _simple(index, size),
      HitboxKind.polygons => _polygon(size),
      HitboxKind.paths => _path(size),
      HitboxKind.mixed => switch (index % 4) {
        0 || 1 => _simple(index, size),
        2 => _polygon(size),
        _ => _path(size),
      },
      HitboxKind.stubMiss => _StubHitbox(size, hits: false),
      HitboxKind.stubHit => _StubHitbox(size, hits: true),
      HitboxKind.circlesMiss => throw ArgumentError.value(kind),
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

  static ShapeHitbox _simple(int index, double size) {
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

  static ShapeHitbox _polygon(double size) {
    return PolygonHitbox(
      _starVertices(size),
      collisionType: CollisionType.inactive,
    );
  }

  static ShapeHitbox _path(double size) {
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
  static List<Vector2> _starVertices(double size) {
    return [
      for (var i = 0; i < 24; i++)
        Vector2(
          size / 2 + (i.isEven ? size / 2 : size / 5) * cos(i * pi / 12),
          size / 2 + (i.isEven ? size / 2 : size / 5) * sin(i * pi / 12),
        ),
    ];
  }
}

/// A rectangle whose ray intersection does not allocate: it is never hit, or
/// it is hit where the ray enters its box.
class _StubHitbox extends RectangleHitbox {
  _StubHitbox(double size, {required this.hits})
    : super(size: Vector2.all(size), collisionType: CollisionType.inactive);

  final bool hits;
  final _normal = Vector2(0, -1);
  final _reflection = Ray2.zero();

  @override
  RaycastResult<ShapeHitbox>? rayIntersection(
    Ray2 ray, {
    RaycastResult<ShapeHitbox>? out,
  }) {
    if (!hits) {
      out?.reset();
      return null;
    }
    final box = aabb;
    var entry = 0.0;
    var exit = double.infinity;
    if (ray.direction.x == 0) {
      if (ray.origin.x < box.min.x || ray.origin.x > box.max.x) {
        return null;
      }
    } else {
      final a = (box.min.x - ray.origin.x) / ray.direction.x;
      final b = (box.max.x - ray.origin.x) / ray.direction.x;
      entry = max(entry, min(a, b));
      exit = min(exit, max(a, b));
    }
    if (ray.direction.y == 0) {
      if (ray.origin.y < box.min.y || ray.origin.y > box.max.y) {
        return null;
      }
    } else {
      final a = (box.min.y - ray.origin.y) / ray.direction.y;
      final b = (box.max.y - ray.origin.y) / ray.direction.y;
      entry = max(entry, min(a, b));
      exit = min(exit, max(a, b));
    }
    if (entry > exit) {
      return null;
    }
    return out!..setWith(
      hitbox: this,
      reflectionRay: _reflection,
      normal: _normal,
      distance: entry,
    );
  }
}
