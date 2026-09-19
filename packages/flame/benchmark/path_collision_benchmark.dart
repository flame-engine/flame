// ignore_for_file: avoid_print

import 'dart:math';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_test/test_paths.dart';

import 'common.dart';

/// Benchmarks the collision detection system when one of the shapes is a
/// hitbox sampled from a [Path] contour, against every other hitbox type and
/// against itself.
///
/// The same scenes are also run with a hand-written polygon of the same
/// shape, which is what a game on main would use instead of a [Path]. The
/// polygon scenes compile on main as well, so the two branches can be compared
/// by running this file on both.
const _amountPerKind = 50;
const _amountTicks = 20;
const _worldSize = 800.0;

/// The subject is the shape under test, the other is what it collides with.
enum ShapeKind { circle, rectangle, polygon, path }

/// The anchor points of [TestPaths.flame], which is
/// what a hand-written polygon of that shape would look like.
final _flameVertices = [
  Vector2(62.0, 42.8),
  Vector2(33.0, 65.0),
  Vector2(4.0, 42.8),
  Vector2(6.5, 32.2),
  Vector2(11.9, 38.8),
  Vector2(23.8, 15.2),
  Vector2(26.4, 26.8),
  Vector2(32.7, 3.0),
  Vector2(44.7, 28.1),
  Vector2(59.3, 28.3),
];
const _flameBounds = Rect.fromLTRB(4, 3, 62, 65);

class PathCollisionBenchmark extends AsyncBenchmarkBase {
  final Random random;
  final ShapeKind subject;
  final ShapeKind other;

  late final FlameGame _game;

  PathCollisionBenchmark(this.random, this.subject, this.other)
    : super('${subject.name} vs ${other.name}');

  @override
  Future<void> setup() async {
    _game = _CollisionGame();
    final shapes = [
      for (var i = 0; i < _amountPerKind; i++) _shape(subject, other),
      for (var i = 0; i < _amountPerKind; i++) _shape(other, subject),
    ];
    _game.world.addAll(shapes);
    await mountGame(_game, size: Vector2.all(_worldSize));
  }

  _MovingShape _shape(ShapeKind kind, ShapeKind partnerKind) {
    final size = Vector2.all(40 + random.nextDouble() * 40);
    return _MovingShape(
      kind: kind,
      partnerKind: partnerKind,
      position: Vector2.random(random) * _worldSize,
      size: size,
      velocity: Vector2(
        random.nextInt(200) * (random.nextBool() ? 1.0 : -1.0),
        random.nextInt(200) * (random.nextBool() ? 1.0 : -1.0),
      ),
      rotationSpeed: random.nextDouble() - 0.5,
    );
  }

  @override
  Future<void> run() async {
    for (var i = 0; i < _amountTicks; i++) {
      _game.update(1 / 60);
    }
  }
}

class _CollisionGame extends FlameGame with HasCollisionDetection {}

class _MovingShape extends PositionComponent with CollisionCallbacks {
  final Vector2 velocity;
  final double rotationSpeed;
  late final ShapeHitbox hitbox;

  _MovingShape({
    required ShapeKind kind,
    required ShapeKind partnerKind,
    required super.position,
    required super.size,
    required this.velocity,
    required this.rotationSpeed,
  }) : super(anchor: Anchor.center) {
    hitbox = switch (kind) {
      ShapeKind.circle => _Circle(),
      ShapeKind.rectangle => _Rectangle(),
      ShapeKind.polygon => _flamePolygonHitbox(size),
      ShapeKind.path => _flamePathHitbox(size),
    };
    (hitbox as _PartnerFilter)
      ..kind = kind
      ..partnerKind = partnerKind;
    add(hitbox);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.add(velocity * dt);
    position.x %= _worldSize;
    position.y %= _worldSize;
    angle += rotationSpeed * dt;
  }
}

/// Only lets the hitbox intersect shapes of [partnerKind], so that a scene
/// measures the subject against the other kind and not the subjects among
/// themselves. The broadphase still sees every hitbox.
mixin _PartnerFilter on ShapeHitbox {
  late final ShapeKind kind;
  late final ShapeKind partnerKind;

  @override
  bool possiblyIntersects(ShapeHitbox other) {
    return other is _PartnerFilter &&
        other.kind == partnerKind &&
        super.possiblyIntersects(other);
  }
}

class _Circle extends CircleHitbox with _PartnerFilter {}

class _Rectangle extends RectangleHitbox with _PartnerFilter {}

class _Polygon extends PolygonHitbox with _PartnerFilter {
  _Polygon(super.vertices, {super.anchor, super.position});

  _Polygon.fromPath(super.path, {super.anchor, super.position})
    : super.fromPath();
}

_Polygon _flamePolygonHitbox(Vector2 size) {
  final scale = size.y / _flameBounds.height;
  final center = Vector2(_flameBounds.center.dx, _flameBounds.center.dy);
  final vertices = _flameVertices
      .map((vertex) => (vertex - center)..scale(scale))
      .toList(growable: false);
  return _Polygon(vertices, anchor: Anchor.center, position: size / 2);
}

_Polygon _flamePathHitbox(Vector2 size) {
  final path = TestPaths.byName('flame', size.toSize());
  return _Polygon.fromPath(path, anchor: Anchor.center, position: size / 2);
}

Future<void> main() async {
  final size = Vector2.all(60);
  print(
    'Vertices at 60px: '
    'polygon ${_flamePolygonHitbox(size).vertices.length}, '
    'path ${_flamePathHitbox(size).vertices.length}',
  );
  const pairs = [
    (ShapeKind.path, ShapeKind.circle),
    (ShapeKind.path, ShapeKind.rectangle),
    (ShapeKind.path, ShapeKind.polygon),
    (ShapeKind.path, ShapeKind.path),
    (ShapeKind.polygon, ShapeKind.circle),
    (ShapeKind.polygon, ShapeKind.rectangle),
    (ShapeKind.polygon, ShapeKind.polygon),
  ];
  for (final (subject, other) in pairs) {
    await PathCollisionBenchmark(Random(69420), subject, other).report();
  }
}
