import 'package:doc_flame_examples/flower.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';

class ScaleByEffectGame extends FlameGame {
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
        flower.add(
          ScaleEffect.by(
            reverse ? Vector2.all(1.5) : Vector2.all(1 / 1.5),
            EffectController(duration: 0.3),
            onComplete: () => hold = false,
          ),
        );
        reverse = !reverse;
      },
    );
    add(flower);
  }
}
