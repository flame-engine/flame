import 'package:flame/collision_detection.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart' hide Image, Draggable;

class CirclesExample extends FlameGame with HasCollisionDetection, TapDetector {
  static const description = '''
    This example will create a circle every time you tap on the screen. It will
    have the initial velocity towards the center of the screen and if it touches
    another circle both of them will change color.
  ''';

  @override
  Future<void> onLoad() async {
    add(ScreenCollidable());
  }

  @override
  void onTapDown(TapDownInfo info) {
    add(MyCollidable(info.eventPosition.game));
  }
}

class MyCollidable extends PositionComponent
    with HasGameRef<CirclesExample>, CollisionCallbacks<PositionComponent> {
  late Vector2 velocity;
  final _collisionColor = Colors.amber;
  final _defaultColor = Colors.cyan;
  late HitboxShape hitbox;

  MyCollidable(Vector2 position)
      : super(
          position: position,
          size: Vector2.all(100),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    final defaultPaint = Paint()
      ..color = _defaultColor
      ..style = PaintingStyle.stroke;
    hitbox = HitboxCircle()
      ..paint = defaultPaint
      ..renderShape = true;
    add(hitbox);
    final center = gameRef.size / 2;
    velocity = (center - position)..scaleTo(150);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.add(velocity * dt);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    hitbox.paint.color = _collisionColor;
    if (other is ScreenCollidable) {
      removeFromParent();
      return;
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (!isColliding) {
      hitbox.paint.color = _defaultColor;
    }
  }
}
