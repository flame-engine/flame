import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class BouncingBallExample extends FlameGame with HasCollisionDetection {
  static const description = '''
    This example shows how you can use the Collisions detection api to know when a ball
    collides with the walls we set up and then update it to bounce off these walls.
  ''';
  @override
  Future<void>? onLoad() {
    final boundaries = createBoundaries();

    boundaries.forEach(add);

    addAll([
      Ball(),
    ]);
    return super.onLoad();
  }
}

class Ball extends CircleComponent
    with HasGameRef<FlameGame>, CollisionCallbacks {
  late Vector2 velocity;

  Ball() {
    paint = Paint()..color = Colors.white;
    radius = 10;
  }

  static const double speed = 500;
  static const degree = math.pi / 180;

  @override
  Future<void>? onLoad() {
    _resetBall;
    final hitBox = CircleHitbox(
      radius: radius,
    );

    addAll([
      hitBox,
    ]);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
  }

  void get _resetBall {
    position = gameRef.size / 2;
    final spawnAngle = getSpawnAngle;

    final vx = math.cos(spawnAngle * degree) * speed;
    final vy = math.sin(spawnAngle * degree) * speed;
    velocity = Vector2(
      vx,
      vy,
    );
  }

  double get getSpawnAngle {
    final random = math.Random().nextDouble();
    final spawnAngle = lerpDouble(0, 360, random)!;

    return spawnAngle;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Boundary) {
      final side = other.side;

      switch (side) {
        case BoundarySide.right:
          velocity.x = -velocity.x;
          velocity.y = velocity.y;

          break;
        case BoundarySide.left:
          velocity.x = -velocity.x;
          velocity.y = velocity.y;
          break;
        case BoundarySide.top:
          velocity.x = velocity.x;
          velocity.y = -velocity.y;
          break;
        case BoundarySide.bottom:
          velocity.x = velocity.x;
          velocity.y = -velocity.y;
          break;
        default:
      }
    }
  }
}

enum BoundarySide {
  top,
  bottom,
  left,
  right;

  Vector2 getSidePosition(FlameGame game) {
    switch (this) {
      case BoundarySide.top:
        return Vector2(0, 0);
      case BoundarySide.bottom:
        return Vector2(0, game.size.y - 5);
      case BoundarySide.left:
        return Vector2(0, 0);
      case BoundarySide.right:
        return Vector2(game.size.x - 5, 0);
      default:
        return Vector2(0, 0);
    }
  }

  Vector2 getSideSize(FlameGame game) {
    switch (this) {
      case BoundarySide.top:
        return Vector2(game.size.x, 5);
      case BoundarySide.bottom:
        return Vector2(game.size.x, 5);
      case BoundarySide.left:
        return Vector2(5, game.size.y);
      case BoundarySide.right:
        return Vector2(5, game.size.y);
      default:
        return Vector2(0, 0);
    }
  }
}

List<Boundary> createBoundaries() {
  return [
    Boundary(
      side: BoundarySide.top,
    ),
    Boundary(
      side: BoundarySide.right,
    ),
    Boundary(
      side: BoundarySide.bottom,
    ),
    Boundary(
      side: BoundarySide.left,
    ),
  ];
}

class Boundary extends PositionComponent
    with HasGameRef<FlameGame>, CollisionCallbacks {
  final BoundarySide side;

  Boundary({
    required this.side,
  });

  @override
  Future<void>? onLoad() {
    final hitBox = RectangleHitbox(
      position: side.getSidePosition(gameRef),
      size: side.getSideSize(gameRef),
    );

    final rectangleComponent = RectangleComponent(
      position: side.getSidePosition(gameRef),
      size: side.getSideSize(gameRef),
      paint: Paint()..color = Colors.white,
    );

    addAll([
      hitBox,
      rectangleComponent,
    ]);
    return super.onLoad();
  }
}
