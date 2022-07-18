import 'package:doc_flame_examples/flower.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/rendering.dart';

class DecoratorRotate3DGame extends FlameGame with HasTappableComponents {
  @override
  Future<void> onLoad() async {
    var step = 0;
    add(
      Flower(
        size: 100,
        position: canvasSize / 2,
        decorator: Rotate3DDecorator()
          ..center = canvasSize / 2
          ..perspective = 0.01,
        onTap: (flower) {
          step++;
          final decorator = flower.decorator! as Rotate3DDecorator;
          if (step == 1) {
            decorator.angleY = -0.8;
          } else if (step == 2) {
            decorator.angleX = 1.0;
          } else if (step == 3) {
            decorator.angleZ = 0.2;
          } else if (step == 4) {
            decorator.angleX = 10;
          } else if (step == 5) {
            decorator.angleY = 2;
          } else {
            decorator
              ..angleX = 0
              ..angleY = 0
              ..angleZ = 0;
            step = 0;
          }
        },
      )..onTapUp(),
    );
  }
}
