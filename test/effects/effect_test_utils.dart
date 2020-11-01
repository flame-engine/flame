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
  bool shouldFinish = true,
  double iterations = 1.0,
  double expectedAngle = 0.0,
  Vector2 expectedPosition,
  Vector2 expectedSize,
}) async {
  expectedPosition ??= Vector2.zero();
  expectedSize ??= Vector2.all(100.0);
  final Callback callback = Callback();
  effect.onComplete = callback.call;
  final BaseGame game = BaseGame();
  game.add(component);
  component.addEffect(effect);
  final double duration = effect.iterationTime;
  await tester.pumpWidget(game.widget);
  double timeLeft = iterations * duration;
  while (timeLeft > 0) {
    double stepDelta = 50.0 + random.nextInt(50);
    stepDelta /= 1000;
    stepDelta = stepDelta < timeLeft ? stepDelta : timeLeft;
    game.update(stepDelta);
    timeLeft -= stepDelta;
  }
  if (!shouldFinish) {
    const double floatRange = 0.001;
    bool acceptableVector(Vector2 vector, Vector2 expectedVector) {
      return (expectedVector - vector).length < floatRange;
    }

    final bool acceptablePosition =
        acceptableVector(component.position, expectedPosition);
    final bool acceptableSize = acceptableVector(component.size, expectedSize);
    final bool acceptableAngle =
        (expectedAngle - component.angle).abs() < floatRange;
    assert(
      acceptablePosition,
      "Position is not correct (had: ${component.position} should be $expectedPosition)",
    );
    assert(
      acceptableAngle,
      "Angle is not correct (had: ${component.angle} should be: $expectedAngle)",
    );
    assert(
      acceptableSize,
      "Size is not correct (had: ${component.size} should be: $expectedSize)",
    );
  } else {
    game.update(0.1);
    expect(
      component.position,
      expectedPosition,
      reason: "Position is not exactly correct",
    );
    expect(
      component.angle,
      expectedAngle,
      reason: "Angle is not exactly correct",
    );
    expect(
      component.size,
      expectedSize,
      reason: "Size is not exactly correct",
    );
  }
  expect(effect.hasFinished(), shouldFinish, reason: "Effect shouldFinish");
  expect(callback.isCalled, shouldFinish, reason: "Callback was treated wrong");
  game.update(0.0); // Since effects are removed before they are updated
  expect(component.effects.isEmpty, shouldFinish);
}

class TestComponent extends PositionComponent {
  TestComponent({
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
