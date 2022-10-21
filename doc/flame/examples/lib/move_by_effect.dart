import 'package:doc_flame_examples/flower.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';

class MoveByEffectGame extends FlameGame with HasTappableComponents {
  bool reset = false;
  @override
  Future<void> onLoad() async {
    final flower = Flower(
      size: 60,
      position: canvasSize / 2,
      onTap: (flower) {
        if (reset = !reset) {
          flower.add(
            MoveEffect.by(
              Vector2(30, 30),
              EffectController(duration: 1.0),
            ),
          );
        } else {
          flower.add(
            MoveEffect.by(
              Vector2(-30, -30),
              EffectController(duration: 1.0),
            ),
          );
        }
      },
    );
    add(flower);
  }
}
