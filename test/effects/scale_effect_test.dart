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
  TestComponent component() => TestComponent(size: randomVector2());

  ScaleEffect effect(bool isInfinite, bool isAlternating) {
    return ScaleEffect(
      size: argumentSize,
      duration: 1 + random.nextInt(100).toDouble(),
      isInfinite: isInfinite,
      isAlternating: isAlternating,
    );
  }

  testWidgets('ScaleEffect can scale', (WidgetTester tester) async {
    effectTest(
      tester,
      component(),
      effect(false, false),
      expectedSize: argumentSize,
    );
  });

  testWidgets(
    'ScaleEffect will stop scaling after it is done',
    (WidgetTester tester) async {
      effectTest(
        tester,
        component(),
        effect(false, false),
        expectedSize: argumentSize,
        iterations: 1.5,
      );
    },
  );

  testWidgets('ScaleEffect can alternate', (WidgetTester tester) async {
    final PositionComponent positionComponent = component();
    effectTest(
      tester,
      positionComponent,
      effect(false, true),
      expectedSize: positionComponent.size.clone(),
    );
  });

  testWidgets(
    'ScaleEffect can alternate and be infinite',
    (WidgetTester tester) async {
      final PositionComponent positionComponent = component();
      effectTest(
        tester,
        positionComponent,
        effect(true, true),
        expectedSize: positionComponent.size.clone(),
        iterations: 1.0,
        shouldFinish: false,
      );
    },
  );

  testWidgets('ScaleEffect alternation can peak', (WidgetTester tester) async {
    final PositionComponent positionComponent = component();
    effectTest(
      tester,
      positionComponent,
      effect(false, true),
      expectedSize: argumentSize,
      shouldFinish: false,
      iterations: 0.5,
    );
  });

  testWidgets('ScaleEffect can be infinite', (WidgetTester tester) async {
    final PositionComponent positionComponent = component();
    effectTest(
      tester,
      positionComponent,
      effect(true, false),
      expectedSize: argumentSize,
      iterations: 3.0,
      shouldFinish: false,
    );
  });
}
