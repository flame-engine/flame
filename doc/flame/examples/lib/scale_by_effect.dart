import 'package:doc_flame_examples/flower.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';

class ScaleByEffectGame extends FlameGame with HasTappableComponents {
  bool reverse = false;
  bool hold = false;
  @override
  Future<void> onLoad() async {
    final flower = Flower(
      size: 60,
      position: canvasSize / 2,
      onTap: (flower) {
        if (hold) {
          return;
        }
        hold = true;
        if (reverse = !reverse) {
          flower.add(
            ScaleEffect.by(
              Vector2.all(1.5),
              EffectController(duration: 0.3),
              onComplete: () => hold = false,
            ),
          );
        } else {
          flower.add(
            ScaleEffect.by(
              Vector2.all(1 / 1.5),
              EffectController(duration: 0.3),
              onComplete: () => hold = false,
            ),
          );
        }
      },
    );
    add(flower);
  }
}
