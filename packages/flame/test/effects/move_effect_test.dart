import 'dart:math';

import 'package:flame/effects.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'effect_test_utils.dart';

class _Elements extends BaseElements {
  _Elements(Random random) : super(random);

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
  group('MoveEffect', () {
    testWidgetsRandom(
      'can move',
      (Random random, WidgetTester tester) async {
        final e = _Elements(random);
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
      'will stop moving after it is done',
      (Random random, WidgetTester tester) async {
        final e = _Elements(random);
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
      'can alternate',
      (Random random, WidgetTester tester) async {
        final e = _Elements(random);
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
      'can alternate and be infinite',
      (Random random, WidgetTester tester) async {
        final e = _Elements(random);
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
      'alternation can peak',
      (Random random, WidgetTester tester) async {
        final e = _Elements(random);
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
      'can be infinite',
      (Random random, WidgetTester tester) async {
        final e = _Elements(random);
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
  });
}
