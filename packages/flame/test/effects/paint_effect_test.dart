import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

class MyComponent extends PositionComponent with HasPaint {}

class MyGame extends BaseGame {}

void main() {
  group('Paint Effects', () {
    group('OpacityEffect', () {
      test(
        'Sets the correct opacity on the paint',
        () {
          final comp = MyComponent();
          final game = MyGame();

          game.onGameResize(Vector2.all(100));
          game.add(comp);
          game.update(0); // Making sure the component was added

          comp.addEffect(
            OpacityEffect(
              opacity: 0,
              duration: 1,
            ),
          );

          game.update(0.2);

          expect(comp.paint.color.opacity, 0.8);
        },
      );
    });

    group('ColorEffect', () {
      test(
        'Sets the correct color filter on the paint',
        () {
          final comp = MyComponent();
          final game = MyGame();

          game.onGameResize(Vector2.all(100));
          game.add(comp);
          game.update(0); // Making sure the component was added

          comp.addEffect(
            ColorEffect(
              color: const Color(0xFF000000),
              duration: 1,
            ),
          );

          game.update(0.5);

          expect(
            comp.paint.colorFilter,
            const ColorFilter.mode(Color(0xFF7F7F7F), BlendMode.multiply),
          );
        },
      );
    });
  });
}
