import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../ember_quest.dart';
import '../managers/segment_manager.dart';

class GroundBlock extends SpriteComponent with HasGameRef<EmberQuestGame> {
  final Vector2 gridPosition;
  double xOffset;
  final GlobalKey _blockKey = GlobalKey();

  GroundBlock({
    required this.gridPosition,
    required this.xOffset,
  }) : super(size: Vector2.all(64), anchor: Anchor.bottomLeft);

  @override
  Future<void> onLoad() async {
    final groundImage = gameRef.images.fromCache('ground.png');
    sprite = Sprite(groundImage);
    position = Vector2(
      (gridPosition.x * size.x) + xOffset,
      gameRef.size.y - (gridPosition.y * size.y),
    );
    add(RectangleHitbox()..collisionType = CollisionType.passive);
    if (gridPosition.x == 9 && position.x > gameRef.lastBlockXPosition) {
      gameRef.lastBlockKey = _blockKey;
      gameRef.lastBlockXPosition = position.x + size.x;
    }
  }

  @override
  void update(double dt) {
    final velocity = Vector2(gameRef.objectSpeed, 0);
    position += velocity * dt;

    if (position.x < -size.x) {
      removeFromParent();
      if (gridPosition.x == 0) {
        gameRef.loadGameSegments(
          Random().nextInt(segments.length + 1),
          gameRef.lastBlockXPosition,
        );
      }
    }
    if (gridPosition.x == 9) {
      if (gameRef.lastBlockKey == _blockKey) {
        gameRef.lastBlockXPosition = position.x + size.x - 10;
      }
    }
    if (gameRef.health <= 0) {
      removeFromParent();
    }

    super.update(dt);
  }
}
