// ignore_for_file: unused_field

import 'dart:math';
import 'dart:ui';

import 'package:crystal_ball/src/game/constants.dart';
import 'package:crystal_ball/src/game/entities/ground.dart';
import 'package:crystal_ball/src/game/game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

class TheBall extends PositionComponent
    with CollisionCallbacks, HasGameReference<CrystalBallGame> {
  TheBall({
    required Vector2 super.position,
  }) : super(
         anchor: Anchor.center,
         priority: 100000,
         children: [
           CircleHitbox(
             radius: kPlayerRadius,
             anchor: Anchor.center,
           ),
         ],
       );

  final Vector2 velocity = Vector2.zero();

  final double _gravity = kGravity;

  late double gamma = 0.6;
  double get radius => (1.0 - gamma) / 3;

  final effectController = CurvedEffectController(
    0.4,
    Curves.easeInOut,
  )..setToEnd();

  void jump() {
    velocity.y = -kJumpVelocity;
  }

  @override
  void update(double dt) {
    super.update(dt);

    velocity.y += 8500 * dt;
    final horizontalV = pow(velocity.y.abs(), 1.8) * 0.0015;
    velocity.x = game.inputHandler.directionalCoefficient * horizontalV;

    final maxH = kCameraSize.x / 2 - kPlayerRadius - 50;

    position += velocity * dt;
    position.x = clampDouble(x, -maxH, maxH);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Ground || other is ParentIsA<Ground>) {
      velocity.y = 0;
      position.y = 0;
      jump();

      game.world.cameraTarget.go(
        to: Vector2(0, -200),
        duration: 0.5,
      );
    }
  }
}
