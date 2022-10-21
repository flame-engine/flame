import 'package:EmberQuest/ember_quest.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class Star extends SpriteComponent with HasGameRef<EmberQuestGame> {
  late Vector2 _gridPosition;
  late double _xPositionOffset;
  Star({
    required Vector2 gridPosition,
    required double xPositionOffset,
  }) : super(size: Vector2.all(64), anchor: Anchor.center) {
    _gridPosition = gridPosition;
    _xPositionOffset = xPositionOffset;
  }

  @override
  Future<void> onLoad() async {
    final starImage = gameRef.images.fromCache('star.png');
    sprite = Sprite(starImage);
    position = Vector2(
        (_gridPosition.x * size.x) + _xPositionOffset + (size.x / 2),
        gameRef.size.y - (_gridPosition.y * size.y) - (size.y / 2));
    add(RectangleHitbox()..collisionType = CollisionType.passive);
    add(
      SizeEffect.by(
        Vector2(-24, -24),
        EffectController(
          duration: .75,
          reverseDuration: .5,
          infinite: true,
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  @override
  void update(double dt) {
    Vector2 velocity = Vector2(gameRef.objectSpeed, 0);
    position += velocity * dt;
    if (position.x < -size.x || gameRef.health <= 0) {
      removeFromParent();
    }
    super.update(dt);
  }
}
