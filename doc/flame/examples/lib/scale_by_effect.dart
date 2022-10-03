import 'package:doc_flame_examples/flower.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';

class ScaleByEffectGame extends FlameGame with HasTappableComponents {
  @override
  Future<void> onLoad() async {
    final effect = ScaleEffect.by(
      Vector2.all(1.5),
      EffectController(duration: 0.3),
    );
    final flower = Flower(
      size: 60,
      position: canvasSize / 2,
      onTap: (flower) {
        flower.add(effect);
      },
    );
    add(flower);
  }
}
