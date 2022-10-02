import 'package:doc_flame_examples/flower.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';

class AnchorByEffectGame extends FlameGame with HasTappableComponents {
  @override
  Future<void> onLoad() async {
    final effect =
        AnchorByEffect(Vector2(0.5, 0.5), EffectController(speed: 1));
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
