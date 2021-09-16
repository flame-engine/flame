import 'dart:math';

import 'package:flame/effects.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'effect_test_utils.dart';

class Elements extends BaseElements {
  Elements(Random random) : super(random);

  @override
  TestComponent component() => TestComponent(position: randomVector2());

  MoveEffect effect({bool isInfinite = false, bool isAlternating = false}) {
    return MoveEffect(
      path: path,
      duration: 1 + random.nextInt(100).toDouble(),
      isInfinite: isInfinite,
      isAlternating: isAlternating,
    )..skipEffectReset = true;
  }
}

void main() {
  testWidgetsRandom(
    'MoveEffect can move',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      effectTest(
        tester,
        e.component(),
        e.effect(),
        expectedPosition: e.path.last,
        random: random,
      );
    },
  );

  testWidgetsRandom(
    'MoveEffect will stop moving after it is done',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      effectTest(
        tester,
        e.component(),
        e.effect(),
        expectedPosition: e.path.last,
        iterations: 1.5,
        random: random,
      );
    },
  );

  testWidgetsRandom(
    'MoveEffect can alternate',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      final positionComponent = e.component();
      effectTest(
        tester,
        positionComponent,
        e.effect(isAlternating: true),
        expectedPosition: positionComponent.position.clone(),
        random: random,
      );
    },
  );

  testWidgetsRandom(
    'MoveEffect can alternate and be infinite',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      final positionComponent = e.component();
      effectTest(
        tester,
        positionComponent,
        e.effect(isInfinite: true, isAlternating: true),
        expectedPosition: positionComponent.position.clone(),
        shouldComplete: false,
        random: random,
      );
    },
  );

  testWidgetsRandom(
    'MoveEffect alternation can peak',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      final positionComponent = e.component();
      effectTest(
        tester,
        positionComponent,
        e.effect(isAlternating: true),
        expectedPosition: e.path.last,
        shouldComplete: false,
        iterations: 0.5,
        random: random,
      );
    },
  );

  testWidgetsRandom(
    'MoveEffect can be infinite',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      final positionComponent = e.component();
      effectTest(
        tester,
        positionComponent,
        e.effect(isInfinite: true),
        expectedPosition: e.path.last,
        iterations: 3.0,
        shouldComplete: false,
        random: random,
      );
    },
  );
}
