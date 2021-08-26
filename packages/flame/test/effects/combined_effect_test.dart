import 'dart:math';

import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/src/test_helpers/random_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'effect_test_utils.dart';

class Elements extends BaseElements {
  bool onCompleteCalled = false;

  Elements(Random random) : super(random);

  @override
  TestComponent component() => TestComponent(
        position: randomVector2(),
        size: randomVector2(),
        angle: randomAngle(),
      );

  CombinedEffect effect({
    bool hasAlternatingMoveEffect = false,
    bool hasAlternatingRotateEffect = false,
    bool hasAlternatingSizeEffect = false,
    bool hasAlternatingScaleEffect = false,
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
    final size = SizeEffect(
      size: argumentSize,
      duration: randomDuration(),
      isAlternating: hasAlternatingSizeEffect,
    )..skipEffectReset = true;
    final scale = ScaleEffect(
      scale: argumentScale,
      duration: randomDuration(),
      isAlternating: hasAlternatingScaleEffect,
    )..skipEffectReset = true;
    return CombinedEffect(
      effects: [move, size, rotate, scale],
      onComplete: () => onCompleteCalled = true,
    );
  }
}

void main() {
  testWidgetsRandom(
    'CombinedEffect can combine',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      final positionComponent = e.component();
      final game = BaseGame();
      game.onGameResize(Vector2.zero());
      await game.onLoad();
      final effect = e.effect();
      await game.add(positionComponent);
      await positionComponent.add(effect);
      var timePassed = 0.0;
      const timeStep = 1 / 60;
      while (timePassed <= effect.iterationTime) {
        game.update(timeStep);
        timePassed += timeStep;
      }
      game.update(1000);
      game.update(timeStep);
      game.update(timeStep);
      expect(effect.hasCompleted(), true);
      expect(e.onCompleteCalled, true);
    },
  );

  testWidgetsRandom(
    'CombinedEffect will stop sequence after it is done',
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
    'CombinedEffect can contain alternating MoveEffect',
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
    'CombinedEffect can contain alternating RotateEffect',
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
    'CombinedEffect can contain alternating SizeEffect',
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
