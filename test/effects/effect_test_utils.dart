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
    final double stepDelta = random.nextInt(100) / 1000;
    game.update(stepDelta);
    timeLeft -= stepDelta;
  }
  expect(component.position, expectedPosition);
  expect(component.angle, expectedAngle);
  expect(component.size, expectedSize);
  expect(effect.hasFinished(), hasFinished);
  expect(callback.isCalled, hasFinished);
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
