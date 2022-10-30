import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/rendering.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Shadow3DDecorator', () {
    test('shadow default properties', () {
      final decorator = Shadow3DDecorator();
      expect(decorator.base, Vector2(0, 0));
      expect(decorator.ascent, 0.0);
      expect(decorator.angle, -1.4);
      expect(decorator.xShift, 100.0);
      expect(decorator.yScale, 1.0);
      expect(decorator.blur, 0.0);
      expect(decorator.opacity, 0.6);
    });

    testGolden(
      'shadow behind object',
      (game) async {
        game.addAll([
          Background(const Color(0xffc9c9c9)),
          DecoratedRectangle(
            position: Vector2(20, 30),
            size: Vector2(60, 100),
            paint: Paint()..color = const Color(0xcc199f2b),
            decorator: Shadow3DDecorator(
              base: Vector2(30, 100),
              xShift: 200,
              yScale: 2,
            ),
          ),
        ]);
      },
      size: Vector2(120, 150),
      goldenFile: '../_goldens/shadow3d_decorator_1.png',
    );

    testGolden(
      'shadow in front object',
      (game) async {
        game.addAll([
          Background(const Color(0xffc9c9c9)),
          DecoratedRectangle(
            position: Vector2(60, 20),
            size: Vector2(60, 100),
            paint: Paint()..color = const Color(0xcc199f2b),
            decorator: Shadow3DDecorator(
              base: Vector2(30, 100),
              angle: 1.7,
              xShift: 200,
              yScale: 2,
              opacity: 0.5,
              blur: 2.0,
            ),
          ),
        ]);
      },
      size: Vector2(140, 180),
      goldenFile: '../_goldens/shadow3d_decorator_2.png',
    );

    testGolden(
      'dynamically change shadow properties',
      (game) async {
        game.addAll([
          Background(const Color(0xffc9c9c9)),
          DecoratedRectangle(
            position: Vector2(60, 20),
            size: Vector2(60, 100),
            paint: Paint()..color = const Color(0xcc199f2b),
            decorator: Shadow3DDecorator()
              ..base = Vector2(30, 100)
              ..ascent = 0
              ..angle = 1.8
              ..xShift = 250.0
              ..yScale = 1.5
              ..opacity = 0.4
              ..blur = 1.0,
          ),
        ]);
      },
      size: Vector2(140, 180),
      goldenFile: '../_goldens/shadow3d_decorator_3.png',
    );
  });
}

class DecoratedRectangle extends RectangleComponent {
  DecoratedRectangle({
    super.position,
    super.size,
    super.paint,
    Decorator? decorator,
  }) {
    this.decorator.addLast(decorator);
  }
}

class Background extends Component {
  Background(this.color);
  final Color color;

  @override
  void render(Canvas canvas) {
    canvas.drawColor(color, BlendMode.src);
  }
}
