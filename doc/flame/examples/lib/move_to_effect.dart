import 'package:doc_flame_examples/flower.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';

class MoveToEffectGame extends FlameGame {
  bool reset = false;

  @override
  Future<void> onLoad() async {
    final flower = Flower(
      size: 60,
      position: canvasSize / 2,
      onTap: (flower) {
        flower.add(
          MoveEffect.to(
            reset ? size / 2 : Vector2(30, 30),
            EffectController(duration: 1.0),
          ),
        );
        reset = !reset;
      },
    );
    add(flower);
  }
}
