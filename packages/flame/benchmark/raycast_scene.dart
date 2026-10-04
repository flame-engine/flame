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
enum HitboxKind() {
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
  /// is the cheapest miss of a built-in hitbox, so the ordering of the
  /// candidates is most of the work. The rays and the circles do not depend
  /// on the [RaycastScene].
  circlesMiss;

  /// The kinds that are real shapes.
  static const shapes = [simple, polygons, paths, mixed];
}

/// The sizes of the hitboxes of a scene.
enum RaycastScene(final double minSize, final double maxSize) {
  /// Small hitboxes, so that a ray crosses the boxes of a few of them.
  spread(30, 80),

  /// Hitboxes as big as most of the world, so that a ray crosses the boxes of
  /// many of them, and, with the concave ones, hits few of them.
  dense(300, 500),
}

class RaycastGame() extends FlameGame<RaycastWorld> {
  this : super(world: RaycastWorld());
}

class RaycastWorld() extends World with HasCollisionDetection;

/// A scene of hitboxes in a [RaycastGame], and rays to cast against it. The
/// scene and the rays only depend on the arguments, so the same scene can be
/// built again to compare runs.
class RaycastScenery._(
  final RaycastGame game,
  final List<PositionComponent> components,
  final List<Ray2> rays,
) {
  StandardCollisionDetection<Broadphase<ShapeHitbox>> get detection =>
      game.world.collisionDetection
          as StandardCollisionDetection<Broadphase<ShapeHitbox>>;

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
class _StubHitbox(double size, {required final bool hits})
    extends RectangleHitbox {
  this : super(size: Vector2.all(size), collisionType: CollisionType.inactive);

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
    final entry = ray.entryDistanceToAabb2(aabb);
    if (entry < 0) {
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
