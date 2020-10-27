import 'dart:math';
import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/components/position_component.dart';
import 'package:flame/effects/effects.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final Random random = Random();
  Vector2 randomVector2() => (Vector2.random(random) * 100)..round();
  final List<Vector2> path = List.generate(3, (i) => randomVector2());

  void moveEffectTest(
    WidgetTester tester,
    bool isInfinite,
    bool isAlternating,
    Vector2 expected, {
    bool hasFinished = true,
    double iterations = 1.0,
  }) async {
    final BaseGame game = BaseGame();
    final Vector2 position = randomVector2();
    final PositionComponent component = Square(position);
    final double duration = random.nextDouble() * 10;
    bool isCallbackCalled = false;
    final MoveEffect effect = MoveEffect(
      path: path,
      duration: duration,
      isInfinite: isInfinite,
      isAlternating: isAlternating,
      onComplete: () => isCallbackCalled = true,
    );
    game.add(component);
    component.addEffect(effect);
    await tester.pumpWidget(game.widget);
    double timeLeft = iterations * duration;
    while(timeLeft > 0) {
      final double stepDelta = random.nextDouble() / 10;
      game.update(stepDelta);
      timeLeft -= stepDelta;
    }
    expect(component.position, expected);
    expect(effect.hasFinished(), hasFinished);
    expect(isCallbackCalled, hasFinished);
    game.update(0.0001);
    expect(component.effects.isEmpty, hasFinished);
  }

  testWidgets('MoveEffect can move', (WidgetTester tester) async {
    moveEffectTest(tester, false, false, path.last);
  });

  testWidgets('MoveEffect can alternate', (WidgetTester tester) async {
    print(path);
    moveEffectTest(tester, false, true, path.first, iterations: 2.00);
  });

  testWidgets('MoveEffect can be infinite', (WidgetTester tester) async {
    print(path);
    moveEffectTest(
      tester,
      true,
      false,
      path.last,
      iterations: 2,
      hasFinished: false,
    );
  });
}

class Square extends PositionComponent {
  Square(Vector2 position, {double angle = 0.0}) {
    size = Vector2.all(100.0);
    this.position = position;
    this.angle = angle;
    anchor = Anchor.center;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), Paint()..color = Colors.red);
  }
}
