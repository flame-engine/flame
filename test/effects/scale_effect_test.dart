import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter_test/flutter_test.dart';

import 'effect_test_utils.dart';

void main() {
  final random = Random();
  Vector2 randomVector2() => (Vector2.random(random) * 100)..round();
  final argumentSize = randomVector2();
  TestComponent component() => TestComponent(size: randomVector2());

  ScaleEffect effect({bool isInfinite = false, bool isAlternating = false}) {
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
      effect(),
      expectedSize: argumentSize,
    );
  });

  testWidgets(
    'ScaleEffect will stop scaling after it is done',
    (WidgetTester tester) async {
      effectTest(
        tester,
        component(),
        effect(),
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
      effect(isAlternating: true),
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
        effect(isInfinite: true, isAlternating: true),
        expectedSize: positionComponent.size.clone(),
        shouldComplete: false,
      );
    },
  );

  testWidgets('ScaleEffect alternation can peak', (WidgetTester tester) async {
    final PositionComponent positionComponent = component();
    effectTest(
      tester,
      positionComponent,
      effect(isAlternating: true),
      expectedSize: argumentSize,
      shouldComplete: false,
      iterations: 0.5,
    );
  });

  testWidgets('ScaleEffect can be infinite', (WidgetTester tester) async {
    final PositionComponent positionComponent = component();
    effectTest(
      tester,
      positionComponent,
      effect(isInfinite: true),
      expectedSize: argumentSize,
      iterations: 3.0,
      shouldComplete: false,
    );
  });
}
