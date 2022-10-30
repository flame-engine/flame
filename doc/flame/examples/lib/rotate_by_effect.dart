import 'package:doc_flame_examples/flower.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';

class RotateByEffectGame extends FlameGame with HasTappableComponents {
  bool reset = false;
  @override
  Future<void> onLoad() async {
    final flower = Flower(
      size: 60,
      position: canvasSize / 2,
      onTap: (flower) {
        if (reset = !reset) {
          flower.add(
            RotateEffect.by(
              tau / 4,
              EffectController(duration: 2),
            ),
          );
        } else {
          flower.add(
            RotateEffect.by(
              -tau / 4,
              EffectController(duration: 2),
            ),
          );
        }
      },
    );
    add(flower);
  }
}
