import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MoveAlongPathEffect', () {
    test('relative path', () {
      const tau = Transform2D.tau;
      const x0 = 32.5;
      const y0 = 14.88;
      final game = FlameGame();
      game.onGameResize(Vector2(100, 100));
      final object = PositionComponent()..position = Vector2(x0, y0);
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
        expect(object.position.x, closeTo(x0 + 6 + 50 * cos(a), 0.1));
        expect(object.position.y, closeTo(y0 + 10 + 50 * sin(a), 0.1));
        game.update(0.01);
      }
    });

    test('absolute path', () {
      final game = FlameGame()..onGameResize(Vector2(100, 100));
      final component = PositionComponent()..position = Vector2(17, -5);
      game.add(component);
      game.update(0);

      component.add(
        MoveAlongPathEffect(
          Path()
            ..moveTo(1000, 300)
            ..lineTo(1200, 500),
          EffectController(duration: 1),
          absolute: true,
        ),
      );
      game.update(0);
      for (var i = 0; i < 10; i++) {
        expect(component.position.x, closeTo(1000 + 200 * (i / 10), 1e-10));
        expect(component.position.y, closeTo(300 + 200 * (i / 10), 1e-10));
        game.update(0.1);
      }
    });

    test('absolute oriented path', () {
      final game = FlameGame()..onGameResize(Vector2(100, 100));
      final component = PositionComponent(
        position: Vector2(17, -5),
        angle: -30.5,
      );
      game.add(component);
      game.update(0);

      component.add(
        MoveAlongPathEffect(
          Path() // pythagorean triangle, perimeter=600
            ..moveTo(200, 200)
            ..lineTo(290, 80)
            ..lineTo(450, 200)
            ..lineTo(200, 200),
          EffectController(duration: 6),
          absolute: true,
          oriented: true,
        ),
      );
      game.update(0);
      for (var i = 0; i < 60; i++) {
        if (i <= 15) {
          expect(component.position.x, closeTo(200 + 6 * i, 1e-10));
          expect(component.position.y, closeTo(200 - 8 * i, 1e-10));
          expect(component.angle, closeTo(-asin(0.8), 1e-7));
        } else if (i <= 35) {
          expect(component.position.x, closeTo(290 + 8 * (i - 15), 1e-10));
          expect(component.position.y, closeTo(80 + 6 * (i - 15), 1e-10));
          expect(component.angle, closeTo(asin(0.6), 1e-7));
        } else {
          expect(component.position.x, closeTo(450 - 10 * (i - 35), 1e-10));
          expect(component.position.y, closeTo(200, 1e-10));
          expect(component.angle, closeTo(pi, 1e-7));
        }
        game.update(0.1);
      }
    });

    testWithFlameGame(
      'oriented effect applied to non-orientable target',
      (game) async {
        final world = World()..addToParent(game);
        final camera = CameraComponent(world: world)..addToParent(game);
        await game.ready();
        await camera.viewport.add(
          MoveAlongPathEffect(
            Path()..lineTo(10, 10),
            EffectController(duration: 1),
            oriented: true,
          ),
        );
        expect(
          () => game.update(0),
          failsAssert(
            'An `oriented` MoveAlongPathEffect cannot be applied to a target '
            'that does not support rotation',
          ),
        );
      },
    );

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
