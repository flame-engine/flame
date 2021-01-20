import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
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
  bool shouldComplete = true,
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
  await tester.pumpWidget(GameWidget(
    game: game,
  ));
  double timeLeft = iterations * duration;
  while (timeLeft > 0) {
    double stepDelta = 50.0 + random.nextInt(50);
    stepDelta /= 1000;
    stepDelta = stepDelta < timeLeft ? stepDelta : timeLeft;
    game.update(stepDelta);
    timeLeft -= stepDelta;
  }

  if (!shouldComplete) {
    const double floatRange = 0.01;
    expect(
      component.position.absoluteError(expectedPosition),
      closeTo(0.0, floatRange),
      reason: "Position is not correct",
    );
    expect(
      component.angle,
      closeTo(expectedAngle, floatRange),
      reason: "Angle is not correct",
    );
    expect(
      component.size.absoluteError(expectedSize),
      closeTo(0.0, floatRange),
      reason: "Size is not correct",
    );
  } else {
    // To account for float number operations making effects not finish
    const double epsilon = 0.001;
    if (effect.percentage < epsilon) {
      game.update(effect.currentTime);
    } else if (1.0 - effect.percentage < epsilon) {
      game.update(effect.peakTime - effect.currentTime);
    }

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
  expect(effect.hasCompleted(), shouldComplete, reason: "Effect shouldFinish");
  expect(callback.isCalled, shouldComplete,
      reason: "Callback was treated wrong");
  game.update(0.0); // Since effects are removed before they are updated
  expect(component.effects.isEmpty, shouldComplete);
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
