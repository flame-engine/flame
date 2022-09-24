import 'package:doc_flame_examples/flower.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/rendering.dart';

class DecoratorBlurGame extends FlameGame with HasTappableComponents {
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
            decorator.addLast(PaintDecorator.blur(3.0));
          } else if (step == 2) {
            decorator.replaceLast(PaintDecorator.blur(5.0));
          } else if (step == 3) {
            decorator.replaceLast(PaintDecorator.blur(0.0, 20.0));
          } else {
            decorator.replaceLast(null);
            step = 0;
          }
        },
      )..onTapUp(),
    );
  }
}
