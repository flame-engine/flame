import 'dart:math';

import 'package:flame/components/position_component.dart';
import 'package:flame/effects/effects.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flutter_test/flutter_test.dart';

import 'effect_test_utils.dart';

void main() {
  final Random random = Random();
  Vector2 randomVector2() => (Vector2.random(random) * 100)..round();
  final Vector2 argumentSize = randomVector2();
  Square component() => Square(size: randomVector2());

  ScaleEffect effect(bool isInfinite, bool isAlternating) {
    return ScaleEffect(
      size: argumentSize,
      duration: random.nextDouble() * 100,
      isInfinite: isInfinite,
      isAlternating: isAlternating,
    );
  }

  testWidgets('ScaleEffect can scale', (WidgetTester tester) async {
    final ScaleEffect scaleEffect = effect(false, false);
    effectTest(
      tester,
      component(),
      scaleEffect,
      expectedSize: argumentSize,
    );
  });

  testWidgets(
    'ScaleEffect will stop scaling after it is done',
    (WidgetTester tester) async {
      final ScaleEffect scaleEffect = effect(false, false);
      effectTest(
        tester,
        component(),
        scaleEffect,
        expectedSize: argumentSize,
        iterations: 1.5,
      );
    },
  );

  testWidgets('ScaleEffect can alternate', (WidgetTester tester) async {
    final ScaleEffect scaleEffect = effect(false, true);
    final PositionComponent positionComponent = component();
    effectTest(
      tester,
      positionComponent,
      scaleEffect,
      expectedSize: positionComponent.size.clone(),
    );
  });

  testWidgets(
    'ScaleEffect can alternate and be infinite',
    (WidgetTester tester) async {
      final ScaleEffect scaleEffect = effect(true, true);
      final PositionComponent positionComponent = component();
      effectTest(
        tester,
        positionComponent,
        scaleEffect,
        expectedSize: positionComponent.size.clone(),
        iterations: 1.0,
        hasFinished: false,
      );
    },
  );

  testWidgets('ScaleEffect alternation can peak', (WidgetTester tester) async {
    final ScaleEffect scaleEffect = effect(false, true);
    final PositionComponent positionComponent = component();
    effectTest(
      tester,
      positionComponent,
      scaleEffect,
      expectedSize: argumentSize,
      hasFinished: false,
      iterations: 0.5,
    );
  });

  testWidgets('ScaleEffect can be infinite', (WidgetTester tester) async {
    final ScaleEffect scaleEffect = effect(true, false);
    final PositionComponent positionComponent = component();
    effectTest(
      tester,
      positionComponent,
      scaleEffect,
      expectedSize: argumentSize,
      iterations: 1.0,
      hasFinished: false,
    );
  });

  // TODO: test that tests speed, and not only duration
}
