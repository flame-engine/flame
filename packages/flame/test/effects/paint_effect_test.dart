import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

class MyComponent extends PositionComponent with HasPaint {}

void main() {
  group('Paint Effects', () {
    group('OpacityEffect', () {
      test(
        'Sets the correct opacity on the paint',
        () async {
          final component = MyComponent();
          final game = FlameGame();

          game.onGameResize(Vector2.all(100));
          game.add(component);
          game.update(0); // Making sure the component was added

          await component.add(
            OpacityEffect(
              opacity: 0,
              duration: 1,
            ),
          );

          game.update(0.2);

          expect(component.paint.color.opacity, 0.8);
        },
      );
    });

    group('ColorEffect', () {
      test(
        'Sets the correct color filter on the paint',
        () async {
          final component = MyComponent();
          final game = FlameGame();

          game.onGameResize(Vector2.all(100));
          game.add(component);
          game.update(0); // Making sure the component was added

          await component.add(
            ColorEffect(
              color: const Color(0xFF000000),
              duration: 1,
            ),
          );

          game.update(0.5);

          expect(
            component.paint.colorFilter,
            const ColorFilter.mode(Color(0xFF7F7F7F), BlendMode.multiply),
          );
        },
      );
    });
  });
}
