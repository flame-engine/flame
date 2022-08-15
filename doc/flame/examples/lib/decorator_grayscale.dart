import 'package:doc_flame_examples/flower.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/rendering.dart';

class DecoratorGrayscaleGame extends FlameGame with HasTappableComponents {
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
            decorator.addLast(PaintDecorator.grayscale());
          } else if (step == 2) {
            decorator.replaceLast(PaintDecorator.grayscale(opacity: 0.5));
          } else if (step == 3) {
            decorator.replaceLast(PaintDecorator.grayscale(opacity: 0.2));
          } else if (step == 4) {
            decorator.replaceLast(PaintDecorator.grayscale(opacity: 0.1));
          } else {
            decorator.removeLast();
            step = 0;
          }
        },
      )..onTapUp(),
    );
  }
}
