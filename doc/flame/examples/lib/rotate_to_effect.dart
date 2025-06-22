import 'package:doc_flame_examples/flower.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';

class RotateToEffectGame extends FlameGame {
  bool reset = false;

  @override
  Future<void> onLoad() async {
    final flower = Flower(
      size: 60,
      position: canvasSize / 2,
      onTap: (flower) {
        flower.add(
          RotateEffect.to(
            reset ? tau / 4 : -tau / 4,
            EffectController(duration: 2),
          ),
        );
        reset = !reset;
      },
    );
    add(flower);
  }
}
