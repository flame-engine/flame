import 'package:doc_flame_examples/flower.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';

class ScaleToEffectGame extends FlameGame {
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
          ScaleEffect.to(
            reverse ? Vector2.all(0.5) : Vector2.all(1),
            EffectController(duration: 0.5),
            onComplete: () => hold = false,
          ),
        );
        reverse = !reverse;
      },
    );
    add(flower);
  }
}
