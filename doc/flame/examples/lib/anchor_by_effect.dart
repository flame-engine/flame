import 'package:doc_flame_examples/flower.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';

class AnchorByEffectGame extends FlameGame {
  bool reset = false;

  @override
  Future<void> onLoad() async {
    final flower = Flower(
      size: 60,
      position: canvasSize / 2,
      onTap: (flower) {
        flower.add(
          AnchorByEffect(
            reset ? Vector2(-0.5, -0.5) : Vector2(0.5, 0.5),
            EffectController(speed: 1),
          ),
        );
        reset = !reset;
      },
    );
    add(flower);
  }
}
