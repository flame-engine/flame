import 'package:doc_flame_examples/ember.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide Image, Draggable;

class CollisionDetectionGame extends FlameGame
    with HasCollisionDetection, HasTappableComponents {
  @override
  Future<void> onLoad() async {
    final emberPlayer = EmberPlayer(
      position: Vector2(10, (size.y / 2) - 20),
      size: Vector2.all(40),
      onTap: (emberPlayer) {
        emberPlayer.add(
          MoveEffect.to(
            Vector2(size.x - 40, (size.y / 2) - 20),
            EffectController(
              duration: 5,
              reverseDuration: 5,
              repeatCount: 1,
              curve: Curves.easeOut,
            ),
          ),
        );
      },
    );
    add(emberPlayer);
    add(RectangleCollidable(canvasSize / 2));
  }
}

class RectangleCollidable extends PositionComponent with CollisionCallbacks {
  final _collisionStartColor = Colors.amber;
  final _defaultColor = Colors.cyan;
  late ShapeHitbox hitbox;

  RectangleCollidable(Vector2 position)
      : super(
          position: position,
          size: Vector2.all(50),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    final defaultPaint = Paint()
      ..color = _defaultColor
      ..style = PaintingStyle.stroke;
    hitbox = RectangleHitbox()
      ..paint = defaultPaint
      ..renderShape = true;
    add(hitbox);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    hitbox.paint.color = _collisionStartColor;
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (!isColliding) {
      hitbox.paint.color = _defaultColor;
    }
  }
}
