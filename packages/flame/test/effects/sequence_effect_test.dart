import 'dart:math';

import 'package:flame/effects.dart';
import 'package:flame/src/test_helpers/random_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'effect_test_utils.dart';

class Elements extends BaseElements {
  Elements(Random random) : super(random);

  @override
  TestComponent component() => TestComponent(
        position: randomVector2(),
        size: randomVector2(),
        angle: randomAngle(),
      );

  SequenceEffect effect({
    bool isInfinite = false,
    bool isAlternating = false,
    bool hasAlternatingMoveEffect = false,
    bool hasAlternatingRotateEffect = false,
    bool hasAlternatingSizeEffect = false,
  }) {
    final move = MoveEffect(
      path: path,
      duration: randomDuration(),
      isAlternating: hasAlternatingMoveEffect,
    )..skipEffectReset = true;
    final rotate = RotateEffect(
      angle: argumentAngle,
      duration: randomDuration(),
      isAlternating: hasAlternatingRotateEffect,
    )..skipEffectReset = true;
    final scale = SizeEffect(
      size: argumentSize,
      duration: randomDuration(),
      isAlternating: hasAlternatingSizeEffect,
    )..skipEffectReset = true;
    return SequenceEffect(
      effects: [move, scale, rotate],
      isInfinite: isInfinite,
      isAlternating: isAlternating,
    )..skipEffectReset = true;
  }
}

void main() {
  testWidgetsRandom(
    'SequenceEffect can sequence',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      effectTest(
        tester,
        e.component(),
        e.effect(),
        expectedPosition: e.path.last,
        expectedAngle: e.argumentAngle,
        expectedSize: e.argumentSize,
        random: random,
      );
    },
  );

  testWidgetsRandom(
    'SequenceEffect will stop sequence after it is done',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      effectTest(
        tester,
        e.component(),
        e.effect(),
        expectedPosition: e.path.last,
        expectedAngle: e.argumentAngle,
        expectedSize: e.argumentSize,
        iterations: 1.5,
        random: random,
      );
    },
  );

  testWidgetsRandom(
    'SequenceEffect can alternate',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      final positionComponent = e.component();
      effectTest(
        tester,
        positionComponent,
        e.effect(isAlternating: true),
        expectedPosition: positionComponent.position.clone(),
        expectedAngle: positionComponent.angle,
        expectedSize: positionComponent.size.clone(),
        iterations: 2.0,
        random: random,
      );
    },
  );

  testWidgetsRandom(
    'SequenceEffect can alternate and be infinite',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      final positionComponent = e.component();
      effectTest(
        tester,
        positionComponent,
        e.effect(isInfinite: true, isAlternating: true),
        expectedPosition: positionComponent.position.clone(),
        expectedAngle: positionComponent.angle,
        expectedSize: positionComponent.size.clone(),
        shouldComplete: false,
        epsilon: 3.0,
        random: random,
      );
    },
  );

  testWidgetsRandom(
    'SequenceEffect alternation can peak',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      final positionComponent = e.component();
      effectTest(
        tester,
        positionComponent,
        e.effect(isAlternating: true),
        expectedPosition: e.path.last,
        expectedAngle: e.argumentAngle,
        expectedSize: e.argumentSize,
        shouldComplete: false,
        iterations: 0.5,
        random: random,
      );
    },
  );

  testWidgetsRandom(
    'SequenceEffect can be infinite',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      final positionComponent = e.component();
      effectTest(
        tester,
        positionComponent,
        e.effect(isInfinite: true),
        expectedPosition: e.path.last,
        expectedAngle: e.argumentAngle,
        expectedSize: e.argumentSize,
        iterations: 3.0,
        shouldComplete: false,
        random: random,
      );
    },
  );

  testWidgetsRandom(
    'SequenceEffect can contain alternating MoveEffect',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      final positionComponent = e.component();
      effectTest(
        tester,
        positionComponent,
        e.effect(hasAlternatingMoveEffect: true),
        expectedPosition: positionComponent.position.clone(),
        expectedAngle: e.argumentAngle,
        expectedSize: e.argumentSize,
        random: random,
      );
    },
  );

  testWidgetsRandom(
    'SequenceEffect can contain alternating RotateEffect',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      final positionComponent = e.component();
      effectTest(
        tester,
        positionComponent,
        e.effect(hasAlternatingRotateEffect: true),
        expectedPosition: e.path.last,
        expectedAngle: positionComponent.angle,
        expectedSize: e.argumentSize,
        random: random,
      );
    },
  );

  testWidgetsRandom(
    'SequenceEffect can contain alternating SizeEffect',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      final positionComponent = e.component();
      effectTest(
        tester,
        positionComponent,
        e.effect(hasAlternatingSizeEffect: true),
        expectedPosition: e.path.last,
        expectedAngle: e.argumentAngle,
        expectedSize: positionComponent.size.clone(),
        random: random,
      );
    },
  );
}
