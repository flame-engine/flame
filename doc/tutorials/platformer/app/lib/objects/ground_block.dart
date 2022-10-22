import 'dart:math';

import 'package:ember_quest/ember_quest.dart';
import 'package:ember_quest/managers/segment_manager.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GroundBlock extends SpriteComponent with HasGameRef<EmberQuestGame> {
  late Vector2 _gridPosition;
  late double _xPositionOffset;
  final GlobalKey _blockKey = GlobalKey();

  GroundBlock({
    required Vector2 gridPosition,
    required double xPositionOffset,
  }) : super(size: Vector2.all(64), anchor: Anchor.bottomLeft) {
    _gridPosition = gridPosition;
    _xPositionOffset = xPositionOffset;
  }

  @override
  Future<void> onLoad() async {
    final groundImage = gameRef.images.fromCache('ground.png');
    sprite = Sprite(groundImage);
    position = Vector2((_gridPosition.x * size.x) + _xPositionOffset,
        gameRef.size.y - (_gridPosition.y * size.y));
    add(RectangleHitbox()..collisionType = CollisionType.passive);
    if (_gridPosition.x == 9 && position.x > gameRef.lastBlockXPosition) {
      gameRef.lastBlockKey = _blockKey;
      gameRef.lastBlockXPosition = position.x + size.x;
    }
  }

  @override
  void update(double dt) {
    Vector2 velocity = Vector2(gameRef.objectSpeed, 0);
    position += velocity * dt;

    if (position.x < -size.x) {
      removeFromParent();
      if (_gridPosition.x == 0) {
        gameRef.loadGameSegments(
            Random().nextInt(segments.length + 1), gameRef.lastBlockXPosition);
      }
    }
    if (_gridPosition.x == 9) {
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
