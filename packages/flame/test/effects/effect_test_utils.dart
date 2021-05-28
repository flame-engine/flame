import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util/expect_double.dart';
import '../util/expect_vector2.dart';

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
  Vector2? expectedPosition,
  Vector2? expectedSize,
}) async {
  expectedPosition ??= Vector2.zero();
  expectedSize ??= Vector2.all(100.0);
  final callback = Callback();
  effect.onComplete = callback.call;
  final game = BaseGame();
  game.onResize(Vector2.all(200));
  game.add(component);
  component.addEffect(effect);
  final duration = effect.iterationTime;
  await tester.pumpWidget(GameWidget(
    game: game,
  ));
  var timeLeft = iterations * duration;
  while (timeLeft > 0) {
    var stepDelta = 50.0 + random.nextInt(50);
    stepDelta /= 1000;
    stepDelta = stepDelta < timeLeft ? stepDelta : timeLeft;
    game.update(stepDelta);
    timeLeft -= stepDelta;
  }

  if (!shouldComplete) {
    expectVector2(
      component.position,
      expectedPosition,
      reason: 'Position is not correct',
    );
    expectDouble(
      component.angle,
      expectedAngle,
      reason: 'Angle is not correct',
    );
    expectVector2(
      component.size,
      expectedSize,
      reason: 'Size is not correct',
    );
  } else {
    // To account for float number operations making effects not finish
    const epsilon = 0.001;
    if (effect.percentage! < epsilon) {
      game.update(effect.currentTime);
    } else if (1.0 - effect.percentage! < epsilon) {
      game.update(effect.peakTime - effect.currentTime);
    }

    expectVector2(
      component.position,
      expectedPosition,
      reason: 'Position is not exactly correct',
    );
    expectDouble(
      component.angle,
      expectedAngle,
      reason: 'Angle is not exactly correct',
    );
    expectVector2(
      component.size,
      expectedSize,
      reason: 'Size is not exactly correct',
    );
  }
  expect(effect.hasCompleted(), shouldComplete, reason: 'Effect shouldFinish');
  expect(
    callback.isCalled,
    shouldComplete,
    reason: 'Callback was treated wrong',
  );
  game.update(0.0); // Since effects are removed before they are updated
  expect(component.effects.isEmpty, shouldComplete);
}

class TestComponent extends PositionComponent {
  TestComponent({
    Vector2? position,
    Vector2? size,
    double angle = 0.0,
    Anchor anchor = Anchor.center,
  }) : super(
          position: position,
          size: size ?? Vector2.all(100.0),
          angle: angle,
          anchor: anchor,
        );
}
