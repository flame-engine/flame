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
      bool hitEdges = false,
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
  final double duration = (random.nextDouble() * 100).roundToDouble();
  game.add(component);
  component.addEffect(effect);
  await tester.pumpWidget(game.widget);
  double timeLeft = iterations * duration;
  while(timeLeft > 0) {
    final double stepDelta = hitEdges ? 0.01 : random.nextDouble() / 10;
    game.update(stepDelta);
    timeLeft -= stepDelta;
  }
  expect(effect.hasFinished(), hasFinished);
  expect(callback.isCalled, hasFinished);
  expect(component.angle, expectedAngle);
  expect(component.position, expectedPosition);
  expect(component.size, expectedSize);
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
