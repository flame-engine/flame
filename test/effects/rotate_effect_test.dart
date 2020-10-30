import 'dart:math';

import 'package:flame/components/position_component.dart';
import 'package:flame/effects/effects.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flutter_test/flutter_test.dart';

import 'effect_test_utils.dart';

void main() {
  final Random random = Random();
  double roundDouble(double value, int places) {
    final double mod = pow(10.0, places).toDouble();
    return (value * mod).round().toDouble() / mod;
  }

  // Max three rotations
  double randomAngle() => roundDouble(random.nextDouble() * 6 * pi, 2);
  final double angleArgument = randomAngle();
  Square component() => Square(angle: randomAngle());

  RotateEffect effect(bool isInfinite, bool isAlternating) {
    return RotateEffect(
      angle: angleArgument,
      duration: random.nextDouble() * 100,
      isInfinite: isInfinite,
      isAlternating: isAlternating,
    );
  }

  testWidgets('RotateEffect can rotate', (WidgetTester tester) async {
    final RotateEffect rotateEffect = effect(false, false);
    effectTest(
      tester,
      component(),
      rotateEffect,
      expectedAngle: angleArgument,
    );
  });

  testWidgets(
    'RotateEffect will stop rotating after it is done',
    (WidgetTester tester) async {
      final RotateEffect rotateEffect = effect(false, false);
      effectTest(
        tester,
        component(),
        rotateEffect,
        expectedAngle: angleArgument,
        iterations: 1.5,
      );
    },
  );

  testWidgets('RotateEffect can alternate', (WidgetTester tester) async {
    final RotateEffect rotateEffect = effect(false, true);
    final PositionComponent positionComponent = component();
    effectTest(
      tester,
      positionComponent,
      rotateEffect,
      expectedAngle: positionComponent.angle,
    );
  });

  testWidgets(
    'RotateEffect can alternate and be infinite',
    (WidgetTester tester) async {
      final RotateEffect rotateEffect = effect(true, true);
      final PositionComponent positionComponent = component();
      effectTest(
        tester,
        positionComponent,
        rotateEffect,
        expectedAngle: positionComponent.angle,
        iterations: 1.0,
        hasFinished: false,
      );
    },
  );

  testWidgets('RotateEffect alternation can peak', (WidgetTester tester) async {
    final RotateEffect rotateEffect = effect(false, true);
    final PositionComponent positionComponent = component();
    effectTest(
      tester,
      positionComponent,
      rotateEffect,
      expectedAngle: angleArgument,
      hasFinished: false,
      iterations: 0.5,
    );
  });

  testWidgets('RotateEffect can be infinite', (WidgetTester tester) async {
    final RotateEffect rotateEffect = effect(true, false);
    final PositionComponent positionComponent = component();
    effectTest(
      tester,
      positionComponent,
      rotateEffect,
      expectedAngle: angleArgument,
      iterations: 1.0,
      hasFinished: false,
    );
  });
}
