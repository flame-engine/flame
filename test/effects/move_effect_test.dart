import 'dart:math';

import 'package:flame/components/position_component.dart';
import 'package:flame/effects/effects.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flutter_test/flutter_test.dart';

import 'effect_test_utils.dart';

void main() {
  final Random random = Random();
  Vector2 randomVector2() => (Vector2.random(random) * 100)..round();
  final List<Vector2> path = List.generate(3, (i) => randomVector2());
  Square component() => Square(position: randomVector2());

  MoveEffect effect(bool isInfinite, bool isAlternating) {
    return MoveEffect(
      path: path,
      duration: random.nextDouble() * 100,
      isInfinite: isInfinite,
      isAlternating: isAlternating,
    );
  }

  testWidgets('MoveEffect can move', (WidgetTester tester) async {
    final MoveEffect moveEffect = effect(false, false);
    effectTest(
      tester,
      component(),
      moveEffect,
      expectedPosition: path.last,
    );
  });

  testWidgets(
    'MoveEffect will stop moving after it is done',
        (WidgetTester tester) async {
      final MoveEffect moveEffect = effect(false, false);
      effectTest(
        tester,
        component(),
        moveEffect,
        expectedPosition: path.last,
        iterations: 1.5,
      );
    },
  );

  testWidgets('MoveEffect can alternate', (WidgetTester tester) async {
    final MoveEffect moveEffect = effect(false, true);
    final PositionComponent positionComponent = component();
    effectTest(
      tester,
      positionComponent,
      moveEffect,
      expectedPosition: positionComponent.position.clone(),
    );
  });

  testWidgets(
    'MoveEffect can alternate and be infinite',
        (WidgetTester tester) async {
      final MoveEffect moveEffect = effect(true, true);
      final PositionComponent positionComponent = component();
      effectTest(
          tester,
          positionComponent,
          moveEffect,
          expectedPosition: positionComponent.position.clone(),
          iterations: 1.0,
          hasFinished: false,
      );
    },
  );

  testWidgets('MoveEffect alternation can peak', (WidgetTester tester) async {
    final MoveEffect moveEffect = effect(false, true);
    final PositionComponent positionComponent = component();
    effectTest(
      tester,
      positionComponent,
      moveEffect,
      expectedPosition: path.last,
      hasFinished: false,
      iterations: 0.5,
    );
  });

  testWidgets('MoveEffect can be infinite', (WidgetTester tester) async {
    final MoveEffect moveEffect = effect(true, false);
    final PositionComponent positionComponent = component();
    effectTest(
      tester,
      positionComponent,
      moveEffect,
      expectedPosition: path.last,
      iterations: 1.0,
      hasFinished: false,
    );
  });

  // TODO: test that tests speed, and not only duration
}
