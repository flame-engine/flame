import 'dart:math';

import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/src/test_helpers/random_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'effect_test_utils.dart';

class ReadyGame extends FlameGame {
  ReadyGame() {
    onGameResize(Vector2.zero());
  }
}

class Elements extends BaseElements {
  bool onCompleteCalled = false;

  Elements(Random random) : super(random);

  @override
  TestComponent component() {
    return TestComponent(
      position: randomVector2(),
      size: randomVector2(),
      angle: randomAngle(),
    );
  }

  FlameGame game() => ReadyGame();

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
    )..skipEffectReset = true;
  }
}

void main() {
  testWidgetsRandom(
    'CombinedEffect can combine',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      final component = e.component();
      final game = e.game();
      final effect = e.effect();
      await game.add(component);
      await component.add(effect);
      var timePassed = 0.0;
      const timeStep = 1 / 60;
      while (timePassed <= effect.iterationTime) {
        game.update(timeStep);
        timePassed += timeStep;
      }
      game.update(0);
      expect(effect.hasCompleted(), true);
      expect(e.onCompleteCalled, true);
    },
  );

  testWidgetsRandom(
    'CombinedEffect can not contain children of same type',
    (Random random, WidgetTester tester) async {
      final e = Elements(random);
      final component = e.component();
      final game = e.game();
      final effect = e.effect();
      await game.add(component);
      await component.add(effect);
      game.update(0);
      expect(
        () async => effect.add(SizeEffect(duration: 1.0, size: Vector2.zero())),
        throwsA(isA<AssertionError>()),
      );
    },
  );
}
