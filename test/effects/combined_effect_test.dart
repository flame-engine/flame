import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter_test/flutter_test.dart';

import 'effect_test_utils.dart';

void main() {
  final Random random = Random();
  Vector2 randomVector2() => (Vector2.random(random) * 100)..round();
  double randomAngle() => 1.0 + random.nextInt(5);
  double randomDuration() => 1.0 + random.nextInt(100);
  final Vector2 argumentSize = randomVector2();
  final double argumentAngle = randomAngle();
  final List<Vector2> path = List.generate(3, (i) => randomVector2());
  TestComponent component() {
    return TestComponent(
      position: randomVector2(),
      size: randomVector2(),
      angle: randomAngle(),
    );
  }

  CombinedEffect effect({
    bool isInfinite = false,
    bool isAlternating = false,
    bool hasAlternatingMoveEffect = false,
    bool hasAlternatingRotateEffect = false,
    bool hasAlternatingScaleEffect = false,
  }) {
    final move = MoveEffect(
      path: path,
      duration: randomDuration(),
      isAlternating: hasAlternatingMoveEffect,
    );
    final rotate = RotateEffect(
      angle: argumentAngle,
      duration: randomDuration(),
      isAlternating: hasAlternatingRotateEffect,
    );
    final scale = ScaleEffect(
      size: argumentSize,
      duration: randomDuration(),
      isAlternating: hasAlternatingScaleEffect,
    );
    return CombinedEffect(
      effects: [move, scale, rotate],
      isInfinite: isInfinite,
      isAlternating: isAlternating,
    );
  }

  testWidgets('CombinedEffect can combine', (WidgetTester tester) async {
    final PositionComponent positionComponent = component();
    effectTest(
      tester,
      positionComponent,
      effect(),
      expectedPosition: path.last,
      expectedAngle: argumentAngle,
      expectedSize: argumentSize,
    );
  });

  testWidgets(
    'CombinedEffect will stop sequence after it is done',
    (WidgetTester tester) async {
      effectTest(
        tester,
        component(),
        effect(),
        expectedPosition: path.last,
        expectedAngle: argumentAngle,
        expectedSize: argumentSize,
        iterations: 1.5,
      );
    },
  );

  testWidgets('CombinedEffect can alternate', (WidgetTester tester) async {
    final PositionComponent positionComponent = component();
    effectTest(
      tester,
      positionComponent,
      effect(isAlternating: true),
      expectedPosition: positionComponent.position.clone(),
      expectedAngle: positionComponent.angle,
      expectedSize: positionComponent.size.clone(),
      iterations: 2.0,
    );
  });

  testWidgets(
    'CombinedEffect can alternate and be infinite',
    (WidgetTester tester) async {
      final PositionComponent positionComponent = component();
      effectTest(
        tester,
        positionComponent,
        effect(isInfinite: true, isAlternating: true),
        expectedPosition: positionComponent.position.clone(),
        expectedAngle: positionComponent.angle,
        expectedSize: positionComponent.size.clone(),
        shouldComplete: false,
      );
    },
  );

  testWidgets(
    'CombinedEffect alternation can peak',
    (WidgetTester tester) async {
      final PositionComponent positionComponent = component();
      effectTest(
        tester,
        positionComponent,
        effect(isAlternating: true),
        expectedPosition: path.last,
        expectedAngle: argumentAngle,
        expectedSize: argumentSize,
        shouldComplete: false,
        iterations: 0.5,
      );
    },
  );

  testWidgets('CombinedEffect can be infinite', (WidgetTester tester) async {
    final PositionComponent positionComponent = component();
    effectTest(
      tester,
      positionComponent,
      effect(isInfinite: true),
      expectedPosition: path.last,
      expectedAngle: argumentAngle,
      expectedSize: argumentSize,
      iterations: 3.0,
      shouldComplete: false,
    );
  });

  testWidgets(
    'CombinedEffect can contain alternating MoveEffect',
    (WidgetTester tester) async {
      final PositionComponent positionComponent = component();
      effectTest(
        tester,
        positionComponent,
        effect(hasAlternatingMoveEffect: true),
        expectedPosition: positionComponent.position.clone(),
        expectedAngle: argumentAngle,
        expectedSize: argumentSize,
      );
    },
  );

  testWidgets(
    'CombinedEffect can contain alternating RotateEffect',
    (WidgetTester tester) async {
      final PositionComponent positionComponent = component();
      effectTest(
        tester,
        positionComponent,
        effect(hasAlternatingRotateEffect: true),
        expectedPosition: path.last,
        expectedAngle: positionComponent.angle,
        expectedSize: argumentSize,
      );
    },
  );

  testWidgets(
    'CombinedEffect can contain alternating ScaleEffect',
    (WidgetTester tester) async {
      final PositionComponent positionComponent = component();
      effectTest(
        tester,
        positionComponent,
        effect(hasAlternatingScaleEffect: true),
        expectedPosition: path.last,
        expectedAngle: argumentAngle,
        expectedSize: positionComponent.size.clone(),
      );
    },
  );
}
