import 'dart:math';

import 'package:examples/commons/ember.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class MultipleWorldsExample extends FlameGame {
  static const description = '''
    This example shows how multiple worlds can have discrete collision
    detection.
    
    The top two Embers live in one world and turn green when they collide and
    the bottom two embers live in another world and turn red when they collide,
    you can see that when one of the top ones collide with one of the bottom
    ones, neither change their colors since they are in different worlds.
  ''';

  @override
  Future<void> onLoad() async {
    final world1 = CollisionDetectionWorld();
    final world2 = CollisionDetectionWorld();
    final camera1 = CameraComponent(world: world1);
    final camera2 = CameraComponent(world: world2);
    await addAll([world1, world2, camera1, camera2]);
    final ember1 = CollidableEmber(position: Vector2(75, 75));
    final ember2 = CollidableEmber(position: Vector2(-75, 75));
    final ember3 = CollidableEmber(position: Vector2(75, -75));
    final ember4 = CollidableEmber(position: Vector2(-75, -75));
    world1.addAll([ember1, ember2]);
    world2.addAll([ember3, ember4]);
  }
}

class CollisionDetectionWorld extends World with HasCollisionDetection {}

class CollidableEmber extends Ember with CollisionCallbacks {
  CollidableEmber({super.position});

  static final Random _rng = Random();
  int get index =>
      (position.x.isNegative ? 1 : 0) + (position.y.isNegative ? 2 : 0);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(CircleHitbox());
    add(
      MoveToEffect(
        Vector2.zero(),
        EffectController(
          duration: 0.5 + _rng.nextDouble(),
          infinite: true,
          alternate: true,
        ),
      ),
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    add(
      ColorEffect(
        index < 2 ? Colors.red : Colors.green,
        EffectController(
          duration: 0.2,
          alternate: true,
        ),
        opacityTo: 0.9,
      ),
    );
  }
}
