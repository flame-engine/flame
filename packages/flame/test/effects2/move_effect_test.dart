import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/effects2/move_effect.dart';
import 'package:flame/src/effects2/simple_effect_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MoveEffect', () {
    test('MoveEffect.by()', () {
      final game = FlameGame();
      game.onGameResize(Vector2(100, 100));
      final object = PositionComponent()..position = Vector2(3, 4);
      game.add(object);
      game.update(0);

      object.add(
        MoveEffect.by(Vector2(5, -1), SimpleEffectController(duration: 1)),
      );
      game.update(0.5);
      expect(object.position.x, closeTo(3 + 2.5, 1e-15));
      expect(object.position.y, closeTo(4 + -0.5, 1e-15));
      game.update(0.5);
      expect(object.position.x, closeTo(3 + 5, 1e-15));
      expect(object.position.y, closeTo(4 + -1, 1e-15));
    });

    test('MoveEffect.to()', () {
      final game = FlameGame();
      game.onGameResize(Vector2(100, 100));
      final object = PositionComponent()..position = Vector2(3, 4);
      game.add(object);
      game.update(0);

      object.add(
        MoveEffect.to(Vector2(5, -1), SimpleEffectController(duration: 1)),
      );
      game.update(0.5);
      expect(object.position.x, closeTo(3 * 0.5 + 5 * 0.5, 1e-15));
      expect(object.position.y, closeTo(4 * 0.5 + -1 * 0.5, 1e-15));
      game.update(0.5);
      expect(object.position.x, closeTo(5, 1e-15));
      expect(object.position.y, closeTo(-1, 1e-15));
    });

    test('MoveEffect.along()', () {
      const tau = Transform2D.tau;
      final game = FlameGame();
      game.onGameResize(Vector2(100, 100));
      final object = PositionComponent()..position = Vector2(3, 4);
      game.add(object);
      game.update(0);

      object.add(
        MoveEffect.along(
          Path()
            ..addOval(Rect.fromCircle(center: const Offset(6, 10), radius: 50)),
          SimpleEffectController(duration: 1),
        ),
      );
      game.update(0);
      for (var i = 0; i < 100; i++) {
        final a = tau * i / 100;
        // Apparently, in Flutter circle paths are not truly circles, but only
        // appear circle-ish to an unsuspecting observer. Which is why the
        // precision in `closeTo()` is so low: only 0.1 pixels.
        expect(object.position.x, closeTo(3 + 6 + 50 * cos(a), 0.1));
        expect(object.position.y, closeTo(4 + 10 + 50 * sin(a), 0.1));
        game.update(0.01);
      }
    });

    test('MoveEffect.along() wrong arguments', () {
      final controller = SimpleEffectController();
      expect(
        () => MoveEffect.along(Path(), controller),
        throwsArgumentError,
      );

      final path2 = Path()
        ..moveTo(10, 10)
        ..lineTo(10, 10);
      expect(
        () => MoveEffect.along(path2, controller),
        throwsArgumentError,
      );

      final path3 = Path()
        ..addOval(const Rect.fromLTWH(0, 0, 1, 1))
        ..addOval(const Rect.fromLTWH(2, 2, 1, 1));
      expect(
        () => MoveEffect.along(path3, controller),
        throwsArgumentError,
      );
    });
  });
}
