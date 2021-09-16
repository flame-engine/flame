import 'dart:math';

import 'package:flame/effects.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'effect_test_utils.dart';

class Elements extends BaseElements {
  Elements(Random random) : super(random);

  @override
  TestComponent component() => TestComponent(scale: randomVector2());

  ScaleEffect effect({bool isInfinite = false, bool isAlternating = false}) {
    return ScaleEffect(
      scale: argumentScale,
      duration: 1 + random.nextInt(100).toDouble(),
      isInfinite: isInfinite,
      isAlternating: isAlternating,
    )..skipEffectReset = true;
  }
}

void main() {
  testWidgetsRandom(
    'ScaleEffect can scale',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      effectTest(
        tester,
        e.component(),
        e.effect(),
        expectedScale: e.argumentScale,
        random: random,
      );
    },
  );

  testWidgetsRandom(
    'ScaleEffect will stop scaling after it is done',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      effectTest(
        tester,
        e.component(),
        e.effect(),
        expectedScale: e.argumentScale,
        iterations: 1.5,
        random: random,
      );
    },
  );

  testWidgetsRandom(
    'ScaleEffect can alternate',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      final positionComponent = e.component();
      effectTest(
        tester,
        positionComponent,
        e.effect(isAlternating: true),
        expectedScale: positionComponent.scale.clone(),
        random: random,
      );
    },
  );

  testWidgetsRandom(
    'ScaleEffect can alternate and be infinite',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      final positionComponent = e.component();
      effectTest(
        tester,
        positionComponent,
        e.effect(isInfinite: true, isAlternating: true),
        expectedScale: positionComponent.scale.clone(),
        shouldComplete: false,
        random: random,
      );
    },
  );

  testWidgetsRandom(
    'ScaleEffect alternation can peak',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      final positionComponent = e.component();
      effectTest(
        tester,
        positionComponent,
        e.effect(isAlternating: true),
        expectedScale: e.argumentScale,
        shouldComplete: false,
        iterations: 0.5,
        random: random,
      );
    },
  );

  testWidgetsRandom(
    'ScaleEffect can be infinite',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      final positionComponent = e.component();
      effectTest(
        tester,
        positionComponent,
        e.effect(isInfinite: true),
        expectedScale: e.argumentScale,
        iterations: 3.0,
        shouldComplete: false,
        random: random,
      );
    },
  );
}
