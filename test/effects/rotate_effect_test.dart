import 'package:flame/components/position_component.dart';
import 'package:flame/effects/effects.dart';
import 'package:flutter_test/flutter_test.dart';

import 'effect_test_utils.dart';

void main() {
  const double angleArgument = 6.0;
  TestComponent component() => TestComponent(angle: 0.5);

  RotateEffect effect({bool isInfinite = false, bool isAlternating = false}) {
    return RotateEffect(
      angle: angleArgument,
      duration: 1 + random.nextInt(5).toDouble(),
      isInfinite: isInfinite,
      isAlternating: isAlternating,
    );
  }

  testWidgets('RotateEffect can rotate', (WidgetTester tester) async {
    effectTest(
      tester,
      component(),
      effect(),
      expectedAngle: angleArgument,
    );
  });

  testWidgets(
    'RotateEffect will stop rotating after it is done',
    (WidgetTester tester) async {
      effectTest(
        tester,
        component(),
        effect(),
        expectedAngle: angleArgument,
        iterations: 1.5,
      );
    },
  );

  testWidgets('RotateEffect can alternate', (WidgetTester tester) async {
    final PositionComponent positionComponent = component();
    effectTest(
      tester,
      positionComponent,
      effect(isAlternating: true),
      expectedAngle: positionComponent.angle,
    );
  });

  testWidgets(
    'RotateEffect can alternate and be infinite',
    (WidgetTester tester) async {
      final PositionComponent positionComponent = component();
      effectTest(
        tester,
        positionComponent,
        effect(isInfinite: true, isAlternating: true),
        expectedAngle: positionComponent.angle,
        iterations: 1.0,
        shouldFinish: false,
      );
    },
  );

  testWidgets('RotateEffect alternation can peak', (WidgetTester tester) async {
    final PositionComponent positionComponent = component();
    effectTest(
      tester,
      positionComponent,
      effect(isAlternating: true),
      expectedAngle: angleArgument,
      shouldFinish: false,
      iterations: 0.5,
    );
  });

  testWidgets('RotateEffect can be infinite', (WidgetTester tester) async {
    final PositionComponent positionComponent = component();
    effectTest(
      tester,
      positionComponent,
      effect(isInfinite: true),
      expectedAngle: angleArgument,
      iterations: 3.0,
      shouldFinish: false,
    );
  });
}
