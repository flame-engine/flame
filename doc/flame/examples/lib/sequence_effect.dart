import 'package:doc_flame_examples/flower.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';

class SequenceEffectGame extends FlameGame with HasTappableComponents {
  @override
  Future<void> onLoad() async {
    final effect = SequenceEffect([
      ScaleEffect.by(
        Vector2.all(1.5),
        EffectController(duration: 0.2, alternate: true),
      ),
      MoveEffect.by(Vector2(30, -50), EffectController(duration: 0.5)),
    ]);

    final flower = Flower(
      size: 40,
      position: canvasSize / 2,
      onTap: (flower) {
        flower.add(effect);
      },
    );
    add(flower);
  }
}
