import 'dart:math';

import 'package:example/src/behaviors/behaviors.dart';
import 'package:example/src/example_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_steering_behaviors/flame_steering_behaviors.dart';

class Dot extends PositionedEntity with Steerable {
  Dot({
    super.position,
    Random? random,
  }) : super(
          size: Vector2.all(relativeValue),
          children: [
            CircleComponent.relative(
              1,
              parentSize: Vector2.all(relativeValue),
            ),
          ],
          behaviors: [
            PropagatingCollisionBehavior(CircleHitbox()),
            ScreenCollisionBehavior(),
            WanderBehavior(
              circleDistance: 3 * relativeValue,
              maximumAngle: 45 * degrees2Radians,
              startingAngle: 0,
              random: random,
            ),
          ],
        );

  @override
  double get maxVelocity => 10 * relativeValue;

  @override
  Future<void> onLoad() async {
    parent!.children.register<Dot>();
    await add(
      SeparationBehavior(
        parent!.children.query<Dot>(),
        maxDistance: 1 * relativeValue,
        maxAcceleration: 10 * relativeValue,
      ),
    );
  }
}
