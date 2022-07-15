import 'dart:ui';

import 'package:doc_flame_examples/flower.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/rendering.dart';

class DecoratorTintedGame extends FlameGame with HasTappableComponents {
  @override
  Future<void> onLoad() async {
    var step = 0;
    add(
      Flower(
        size: 100,
        position: canvasSize / 2,
        onTap: (flower) {
          step++;
          if (step == 1) {
            flower.decorator = PaintDecorator.tinted(const Color(0x88FF0000));
          } else if (step == 2) {
            flower.decorator = PaintDecorator.tinted(const Color(0x8800FF00));
          } else if (step == 3) {
            flower.decorator = PaintDecorator.tinted(const Color(0x88000088));
          } else if (step == 4) {
            flower.decorator = PaintDecorator.tinted(const Color(0x66FFFFFF));
          } else if (step == 5) {
            flower.decorator = PaintDecorator.tinted(const Color(0xAA000000));
          } else {
            flower.decorator = null;
            step = 0;
          }
        },
      )..onTapUp(),
    );
  }
}
