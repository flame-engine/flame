import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/rendering.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Rotate3DDecorator', () {
    testGolden(
      'Rotation around X axis',
      (game) async {
        for (var angle = 0.0; angle <= 1.5; angle += 0.5) {
          game.add(
            DecoratedRectangle(
              position: Vector2(20, 30),
              size: Vector2(60, 100),
              paint: Paint()..color = const Color(0x9dde0445),
              decorator: Rotate3DDecorator(
                center: Vector2(50, 80),
                angleX: angle,
                perspective: 0.005,
              ),
            ),
          );
        }
      },
      size: Vector2(100, 160),
      goldenFile: '../_goldens/rotate3d_decorator_1.png',
    );

    testGolden(
      'Rotation around Y axis',
      (game) async {
        for (var angle = 0.0; angle <= 1.5; angle += 0.5) {
          game.add(
            DecoratedRectangle(
              position: Vector2(20, 30),
              size: Vector2(60, 100),
              paint: Paint()..color = const Color(0x9dde0445),
              decorator: Rotate3DDecorator(
                center: Vector2(50, 80),
                angleY: angle,
                perspective: 0.005,
              ),
            ),
          );
        }
      },
      size: Vector2(100, 160),
      goldenFile: '../_goldens/rotate3d_decorator_2.png',
    );

    testGolden(
      'Rotation around all axes',
      (game) async {
        game.add(
          DecoratedRectangle(
            position: Vector2(20, 30),
            size: Vector2(60, 100),
            paint: Paint()..color = const Color(0xff199f2b),
            decorator: Rotate3DDecorator(
              center: Vector2(50, 80),
              angleX: 0.7,
              angleY: 1.0,
              angleZ: 0.5,
              perspective: 0.005,
            ),
          ),
        );
      },
      size: Vector2(100, 160),
      goldenFile: '../_goldens/rotate3d_decorator_3.png',
    );

    test('isFlipped', () {
      final decorator = Rotate3DDecorator();
      expect(decorator.isFlipped, false);
      decorator.angleZ = 2.0;
      expect(decorator.isFlipped, false);
      decorator.angleX = 2.0;
      expect(decorator.isFlipped, true);
      decorator.angleY = 2.0;
      expect(decorator.isFlipped, false);
      decorator.angleY = -0.5;
      expect(decorator.isFlipped, true);
      decorator.angleY = -1.5;
      expect(decorator.isFlipped, true);
      decorator.angleY = -1.6;
      expect(decorator.isFlipped, false);
    });
  });
}

class DecoratedRectangle extends RectangleComponent with HasDecorator {
  DecoratedRectangle({
    super.position,
    super.size,
    super.paint,
    Decorator? decorator,
  }) {
    this.decorator = decorator;
  }
}
