import 'dart:math';

import 'package:doc_flame_examples/flower.dart';
import 'package:flame/game.dart';
import 'package:flame/rendering.dart';

class DecoratorHueGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    var step = 0;
    add(
      Flower(
        size: 100,
        position: canvasSize / 2,
        onTap: (flower) {
          final decorator = flower.decorator;
          step++;
          if (step == 1) {
            decorator.addLast(HueDecorator(hue: pi / 4));
          } else if (step == 2) {
            decorator.replaceLast(HueDecorator(hue: pi / 2));
          } else if (step == 3) {
            decorator.replaceLast(HueDecorator(hue: pi));
          } else {
            decorator.replaceLast(null);
            step = 0;
          }
        },
      )..onTapUp(),
    );
  }
}
