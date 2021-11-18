import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _MyComponent extends PositionComponent with HasPaint {}

void main() {
  group('Paint Effects', () {
    group('OpacityEffect', () {
      flameGame.test(
        'sets the correct opacity on the paint',
        (game) async {
          final component = _MyComponent();
          game.ensureAdd(component);

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
      flameGame.test(
        'sets the correct color filter on the paint',
        (game) async {
          final component = _MyComponent();
          game.ensureAdd(component);

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
