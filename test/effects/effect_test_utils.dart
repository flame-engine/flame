import 'dart:math';

import 'package:flame/anchor.dart';
import 'package:flame/components/position_component.dart';
import 'package:flame/effects/effects.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/game/base_game.dart';
import 'package:flutter_test/flutter_test.dart';

final Random random = Random();

class Callback {
  bool isCalled = false;
  void call() => isCalled = true;
}

void effectTest(
  WidgetTester tester,
  PositionComponent component,
  PositionComponentEffect effect, {
  bool hasFinished = true,
  double iterations = 1.0,
  double expectedAngle = 0.0,
  Vector2 expectedPosition,
  Vector2 expectedSize,
  // Only use when checking a value that is not in
  // the start, end or peak of an iteration
  double floatRange = 0.0,
}) async {
  expectedPosition ??= Vector2.zero();
  expectedSize ??= Vector2.all(100.0);
  final Callback callback = Callback();
  effect.onComplete = callback.call;
  final BaseGame game = BaseGame();
  game.add(component);
  component.addEffect(effect);
  final double duration = effect.totalTravelTime;
  await tester.pumpWidget(game.widget);
  double timeLeft = iterations * duration;
  while (timeLeft > 0) {
    double stepDelta = (50+random.nextInt(50)) / 1000;
    stepDelta = stepDelta < timeLeft ? stepDelta : timeLeft;
    game.update(stepDelta);
    timeLeft -= stepDelta;
  }
  if(effect.driftTime > 0) {
    print("DRIIIIFT ${effect.driftTime} ${effect.travelTime}");
  }
  expect(
    effect.hasFinished(),
    hasFinished,
    reason: "Effect.hasFinished() didn't have the expected value",
  );
  expect(
    callback.isCalled,
    hasFinished,
    reason: 'Callback was not treated properly',
  );
  if (floatRange != 0) {
    bool acceptableVector(Vector2 vector, Vector2 expectedVector) {
      return (expectedVector - vector).length < floatRange;
    }

    final bool acceptablePosition =
        acceptableVector(component.position, expectedPosition);
    final bool acceptableSize = acceptableVector(component.size, expectedSize);
    final bool acceptableAngle =
        (expectedAngle - component.angle).abs() < floatRange;
    assert(acceptablePosition, "Position is not correct");
    assert(acceptableAngle, "Angle is not correct");
    assert(acceptableSize, "Size is not correct");
  } else {
    expect(
      component.position,
      expectedPosition,
      reason: "Position is not correct",
    );
    expect(component.angle, expectedAngle, reason: "Angle is not correct");
    expect(component.size, expectedSize, reason: "Size is not correct");
  }
  game.update(0.0); // Since effects are removed before they are updated
  expect(component.effects.isEmpty, hasFinished);
}

class Square extends PositionComponent {
  Square({
    Vector2 position,
    Vector2 size,
    double angle,
    Anchor anchor,
  }) {
    this.position = position ?? Vector2.zero();
    this.size = size ?? Vector2.all(100.0);
    this.angle = angle ?? 0.0;
    this.anchor = anchor ?? Anchor.center;
  }
}
