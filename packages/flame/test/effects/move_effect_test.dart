import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter_test/flutter_test.dart';

import 'effect_test_utils.dart';

void main() {
  final random = Random();
  Vector2 randomVector2() => (Vector2.random(random) * 100)..round();
  final path = List.generate(3, (i) => randomVector2());
  TestComponent component() => TestComponent(position: randomVector2());

  MoveEffect effect({bool isInfinite = false, bool isAlternating = false}) {
    return MoveEffect(
      path: path,
      duration: 1 + random.nextInt(100).toDouble(),
      isInfinite: isInfinite,
      isAlternating: isAlternating,
    );
  }

  testWidgets('MoveEffect can move', (WidgetTester tester) async {
    effectTest(
      tester,
      component(),
      effect(),
      expectedPosition: path.last,
    );
  });

  testWidgets(
    'MoveEffect will stop moving after it is done',
    (WidgetTester tester) async {
      effectTest(
        tester,
        component(),
        effect(),
        expectedPosition: path.last,
        iterations: 1.5,
      );
    },
  );

  testWidgets('MoveEffect can alternate', (WidgetTester tester) async {
    final PositionComponent positionComponent = component();
    effectTest(
      tester,
      positionComponent,
      effect(isAlternating: true),
      expectedPosition: positionComponent.position.clone(),
    );
  });

  testWidgets(
    'MoveEffect can alternate and be infinite',
    (WidgetTester tester) async {
      final PositionComponent positionComponent = component();
      effectTest(
        tester,
        positionComponent,
        effect(isInfinite: true, isAlternating: true),
        expectedPosition: positionComponent.position.clone(),
        shouldComplete: false,
      );
    },
  );

  testWidgets('MoveEffect alternation can peak', (WidgetTester tester) async {
    final PositionComponent positionComponent = component();
    effectTest(
      tester,
      positionComponent,
      effect(isAlternating: true),
      expectedPosition: path.last,
      shouldComplete: false,
      iterations: 0.5,
    );
  });

  testWidgets('MoveEffect can be infinite', (WidgetTester tester) async {
    final PositionComponent positionComponent = component();
    effectTest(
      tester,
      positionComponent,
      effect(isInfinite: true),
      expectedPosition: path.last,
      iterations: 3.0,
      shouldComplete: false,
    );
  });
}
