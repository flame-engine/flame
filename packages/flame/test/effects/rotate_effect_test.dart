import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter_test/flutter_test.dart';

import 'effect_test_utils.dart';

void main() {
  const defaultAngle = 6.0;
  TestComponent component() => TestComponent(angle: 0.5);

  RotateEffect effect({
    bool isInfinite = false,
    bool isAlternating = false,
    bool isRelative = false,
    double angle = defaultAngle,
  }) {
    return RotateEffect(
      angle: angle,
      duration: 1 + random.nextInt(5).toDouble(),
      isInfinite: isInfinite,
      isAlternating: isAlternating,
      isRelative: isRelative,
    );
  }

  testWidgets('RotateEffect can rotate', (WidgetTester tester) async {
    effectTest(
      tester,
      component(),
      effect(),
      expectedAngle: defaultAngle,
    );
  });

  testWidgets(
    'RotateEffect will stop rotating after it is done',
    (WidgetTester tester) async {
      effectTest(
        tester,
        component(),
        effect(),
        expectedAngle: defaultAngle,
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
      iterations: 2.0,
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
        shouldComplete: false,
      );
    },
  );

  testWidgets('RotateEffect alternation can peak', (WidgetTester tester) async {
    final PositionComponent positionComponent = component();
    effectTest(
      tester,
      positionComponent,
      effect(isAlternating: true),
      expectedAngle: defaultAngle,
      shouldComplete: false,
      iterations: 0.5,
    );
  });

  testWidgets('RotateEffect can be infinite', (WidgetTester tester) async {
    final PositionComponent positionComponent = component();
    effectTest(
      tester,
      positionComponent,
      effect(isInfinite: true),
      expectedAngle: defaultAngle,
      iterations: 3.0,
      shouldComplete: false,
    );
  });

  testWidgets(
    'RotateEffect can handle negative relative angles',
    (WidgetTester tester) async {
      final PositionComponent positionComponent = component();
      effectTest(
        tester,
        positionComponent,
        effect(angle: -1, isRelative: true),
        expectedAngle: component().angle - 1,
      );
    },
  );

  testWidgets(
    'RotateEffect can handle absolute relative angles',
    (WidgetTester tester) async {
      final PositionComponent positionComponent = component();
      effectTest(
        tester,
        positionComponent,
        effect(angle: -1),
        expectedAngle: -1,
      );
    },
  );
}
