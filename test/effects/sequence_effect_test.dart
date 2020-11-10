import 'dart:math';

import 'package:flame/components/position_component.dart';
import 'package:flame/effects/effects.dart';
import 'package:flame/extensions/vector2.dart';
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

  SequenceEffect effect({
    bool isInfinite = false,
    bool isAlternating = false,
    bool hasAlternatingMoveEffect = false,
    bool hasAlternatingRotateEffect = false,
    bool hasAlternatingScaleEffect = false,
  }) {
    final MoveEffect move = MoveEffect(
      path: path,
      duration: randomDuration(),
      isAlternating: hasAlternatingMoveEffect,
    );
    final RotateEffect rotate = RotateEffect(
      angle: argumentAngle,
      duration: randomDuration(),
      isAlternating: hasAlternatingRotateEffect,
    );
    final ScaleEffect scale = ScaleEffect(
      size: argumentSize,
      duration: randomDuration(),
      isAlternating: hasAlternatingScaleEffect,
    );
    return SequenceEffect(
      effects: [move, scale, rotate],
      isInfinite: isInfinite,
      isAlternating: isAlternating,
    );
  }

  testWidgets('SequenceEffect can sequence', (WidgetTester tester) async {
    effectTest(
      tester,
      component(),
      effect(),
      expectedPosition: path.last,
      expectedAngle: argumentAngle,
      expectedSize: argumentSize,
    );
  });

  testWidgets(
    'SequenceEffect will stop sequence after it is done',
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

  testWidgets('SequenceEffect can alternate', (WidgetTester tester) async {
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
    'SequenceEffect can alternate and be infinite',
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

  testWidgets('SequenceEffect alternation can peak',
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
  });

  testWidgets('SequenceEffect can be infinite', (WidgetTester tester) async {
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

  testWidgets('SequenceEffect can contain alternating MoveEffect',
      (WidgetTester tester) async {
    final PositionComponent positionComponent = component();
    effectTest(
      tester,
      positionComponent,
      effect(hasAlternatingMoveEffect: true),
      expectedPosition: positionComponent.position.clone(),
      expectedAngle: argumentAngle,
      expectedSize: argumentSize,
      shouldComplete: true,
    );
  });

  testWidgets('SequenceEffect can contain alternating RotateEffect',
      (WidgetTester tester) async {
    final PositionComponent positionComponent = component();
    effectTest(
      tester,
      positionComponent,
      effect(hasAlternatingRotateEffect: true),
      expectedPosition: path.last,
      expectedAngle: positionComponent.angle,
      expectedSize: argumentSize,
      shouldComplete: true,
    );
  });

  testWidgets('SequenceEffect can contain alternating ScaleEffect',
      (WidgetTester tester) async {
    final PositionComponent positionComponent = component();
    effectTest(
      tester,
      positionComponent,
      effect(hasAlternatingScaleEffect: true),
      expectedPosition: path.last,
      expectedAngle: argumentAngle,
      expectedSize: positionComponent.size.clone(),
      shouldComplete: true,
    );
  });
}
