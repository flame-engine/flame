import 'dart:math';

import 'package:flame/effects.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'effect_test_utils.dart';

class Elements extends BaseElements {
  Elements(Random random) : super(random);

  @override
  TestComponent component() => TestComponent(size: randomVector2());

  SizeEffect effect({bool isInfinite = false, bool isAlternating = false}) {
    return SizeEffect(
      size: argumentSize,
      duration: 1 + random.nextInt(100).toDouble(),
      isInfinite: isInfinite,
      isAlternating: isAlternating,
    )..skipEffectReset = true;
  }
}

void main() {
  testWidgetsRandom(
    'SizeEffect can scale',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      effectTest(
        tester,
        e.component(),
        e.effect(),
        expectedSize: e.argumentSize,
        random: random,
      );
    },
  );

  testWidgetsRandom(
    'SizeEffect will stop scaling after it is done',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      effectTest(
        tester,
        e.component(),
        e.effect(),
        expectedSize: e.argumentSize,
        iterations: 1.5,
        random: random,
      );
    },
  );

  testWidgetsRandom(
    'SizeEffect can alternate',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      final positionComponent = e.component();
      effectTest(
        tester,
        positionComponent,
        e.effect(isAlternating: true),
        expectedSize: positionComponent.size.clone(),
        random: random,
      );
    },
  );

  testWidgetsRandom(
    'SizeEffect can alternate and be infinite',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      final positionComponent = e.component();
      effectTest(
        tester,
        positionComponent,
        e.effect(isInfinite: true, isAlternating: true),
        expectedSize: positionComponent.size.clone(),
        shouldComplete: false,
        random: random,
      );
    },
  );

  testWidgetsRandom(
    'SizeEffect alternation can peak',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      final positionComponent = e.component();
      effectTest(
        tester,
        positionComponent,
        e.effect(isAlternating: true),
        expectedSize: e.argumentSize,
        shouldComplete: false,
        iterations: 0.5,
        random: random,
      );
    },
  );

  testWidgetsRandom(
    'SizeEffect can be infinite',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      final positionComponent = e.component();
      effectTest(
        tester,
        positionComponent,
        e.effect(isInfinite: true),
        expectedSize: e.argumentSize,
        iterations: 3.0,
        shouldComplete: false,
        random: random,
      );
    },
  );
}
