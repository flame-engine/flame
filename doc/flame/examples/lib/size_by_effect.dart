import 'package:doc_flame_examples/flower.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';

class SizeByEffectGame extends FlameGame with HasTappableComponents {
  bool reset = false;
  @override
  Future<void> onLoad() async {
    final flower = Flower(
      size: 60,
      position: canvasSize / 2,
      onTap: (flower) {
        if (reset = !reset) {
          flower.add(
            SizeEffect.by(
              Vector2(20, 20),
              EffectController(duration: 1),
            ),
          );
        } else {
          flower.add(
            SizeEffect.by(
              Vector2(-20, -20),
              EffectController(duration: 1),
            ),
          );
        }
      },
    );
    add(flower);
  }
}
