import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/rendering.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HasDecorator', () {
    testGolden(
      'Component rendering with and without a Decorator',
      (game) async {
        await game.add(
          _DecoratedComponent(
            position: Vector2.all(25),
            size: Vector2.all(40),
          ),
        );
        await game.add(
          _DecoratedComponent(
            position: Vector2(75, 25),
            size: Vector2.all(40),
          )..decorator = (PaintDecorator.grayscale()..addBlur(2)),
        );
      },
      size: Vector2(100, 50),
      goldenFile: '../../_goldens/has_decorator_1.png',
    );
  });
}

class _DecoratedComponent extends PositionComponent with HasDecorator {
  _DecoratedComponent({super.position, super.size})
      : super(anchor: Anchor.center);

  final paint = Paint()..color = const Color(0xff30ccd2);

  @override
  void render(Canvas canvas) {
    final radius = size.x / 2;
    canvas.drawCircle(Offset(radius, radius), radius, paint);
  }
}
