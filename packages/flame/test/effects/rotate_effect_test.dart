import 'dart:math';

import 'package:flame/effects.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'effect_test_utils.dart';

const _defaultAngle = 6.0;

class _Elements extends BaseElements {
  _Elements(Random random) : super(random);

  @override
  TestComponent component() => TestComponent(angle: 0.5);

  RotateEffect effect({
    bool isInfinite = false,
    bool isAlternating = false,
    bool isRelative = false,
    double angle = _defaultAngle,
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
  group('RotateEffect', () {
    testWidgetsRandom(
      'can rotate',
      (Random random, WidgetTester tester) async {
        final e = _Elements(random);
        effectTest(
          tester,
          e.component(),
          e.effect(),
          expectedAngle: _defaultAngle,
          random: random,
        );
      },
    );

    testWidgetsRandom(
      'will stop rotating after it is done',
      (Random random, WidgetTester tester) async {
        final e = _Elements(random);
        effectTest(
          tester,
          e.component(),
          e.effect(),
          expectedAngle: _defaultAngle,
          iterations: 1.5,
          random: random,
        );
      },
    );

    testWidgetsRandom(
      'can alternate',
      (Random random, WidgetTester tester) async {
        final e = _Elements(random);
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
      'can alternate and be infinite',
      (Random random, WidgetTester tester) async {
        final e = _Elements(random);
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
      'alternation can peak',
      (Random random, WidgetTester tester) async {
        final e = _Elements(random);
        final positionComponent = e.component();
        effectTest(
          tester,
          positionComponent,
          e.effect(isAlternating: true),
          expectedAngle: _defaultAngle,
          shouldComplete: false,
          iterations: 0.5,
          random: random,
        );
      },
    );

    testWidgetsRandom(
      'can be infinite',
      (Random random, WidgetTester tester) async {
        final e = _Elements(random);
        final positionComponent = e.component();
        effectTest(
          tester,
          positionComponent,
          e.effect(isInfinite: true),
          expectedAngle: _defaultAngle,
          iterations: 3.0,
          shouldComplete: false,
          random: random,
        );
      },
    );

    testWidgetsRandom(
      'can handle negative relative angles',
      (Random random, WidgetTester tester) async {
        final e = _Elements(random);
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
      'can handle absolute relative angles',
      (Random random, WidgetTester tester) async {
        final e = _Elements(random);
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
  });
}
