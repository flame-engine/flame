import 'dart:math';

import 'package:flame/effects.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'effect_test_utils.dart';

const defaultAngle = 6.0;

class Elements extends BaseElements {
  Elements(Random random) : super(random);

  @override
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
    )..skipEffectReset = true;
  }
}

void main() {
  testWidgetsRandom(
    'RotateEffect can rotate',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      effectTest(
        tester,
        e.component(),
        e.effect(),
        expectedAngle: defaultAngle,
        random: random,
      );
    },
  );

  testWidgetsRandom(
    'RotateEffect will stop rotating after it is done',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      effectTest(
        tester,
        e.component(),
        e.effect(),
        expectedAngle: defaultAngle,
        iterations: 1.5,
        random: random,
      );
    },
  );

  testWidgetsRandom(
    'RotateEffect can alternate',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      final positionComponent = e.component();
      effectTest(
        tester,
        positionComponent,
        e.effect(isAlternating: true),
        expectedAngle: positionComponent.angle,
        iterations: 2.0,
        random: random,
      );
    },
  );

  testWidgetsRandom(
    'RotateEffect can alternate and be infinite',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      final positionComponent = e.component();
      effectTest(
        tester,
        positionComponent,
        e.effect(isInfinite: true, isAlternating: true),
        expectedAngle: positionComponent.angle,
        shouldComplete: false,
        random: random,
      );
    },
  );

  testWidgetsRandom(
    'RotateEffect alternation can peak',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      final positionComponent = e.component();
      effectTest(
        tester,
        positionComponent,
        e.effect(isAlternating: true),
        expectedAngle: defaultAngle,
        shouldComplete: false,
        iterations: 0.5,
        random: random,
      );
    },
  );

  testWidgetsRandom(
    'RotateEffect can be infinite',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      final positionComponent = e.component();
      effectTest(
        tester,
        positionComponent,
        e.effect(isInfinite: true),
        expectedAngle: defaultAngle,
        iterations: 3.0,
        shouldComplete: false,
        random: random,
      );
    },
  );

  testWidgetsRandom(
    'RotateEffect can handle negative relative angles',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      final positionComponent = e.component();
      effectTest(
        tester,
        positionComponent,
        e.effect(angle: -1, isRelative: true),
        expectedAngle: e.component().angle - 1,
        random: random,
      );
    },
  );

  testWidgetsRandom(
    'RotateEffect can handle absolute relative angles',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      final positionComponent = e.component();
      effectTest(
        tester,
        positionComponent,
        e.effect(angle: -1),
        expectedAngle: -1,
        random: random,
      );
    },
  );
}
