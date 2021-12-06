import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/effects/controllers/linear_effect_controller.dart';
import 'package:flame/src/effects/move_along_path_effect.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MoveAlongPathEffect', () {
    test('normal', () {
      const tau = Transform2D.tau;
      final game = FlameGame();
      game.onGameResize(Vector2(100, 100));
      final object = PositionComponent()..position = Vector2(3, 4);
      game.add(object);
      game.update(0);

      object.add(
        MoveAlongPathEffect(
          Path()
            ..addOval(Rect.fromCircle(center: const Offset(6, 10), radius: 50)),
          LinearEffectController(1),
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

    test('errors', () {
      final controller = LinearEffectController(0);
      expect(
        () => MoveAlongPathEffect(Path(), controller),
        throwsArgumentError,
      );

      final path2 = Path()
        ..moveTo(10, 10)
        ..lineTo(10, 10);
      expect(
        () => MoveAlongPathEffect(path2, controller),
        throwsArgumentError,
      );

      final path3 = Path()
        ..addOval(const Rect.fromLTWH(0, 0, 1, 1))
        ..addOval(const Rect.fromLTWH(2, 2, 1, 1));
      expect(
        () => MoveAlongPathEffect(path3, controller),
        throwsArgumentError,
      );
    });
  });
}
