import 'package:doc_flame_examples/flower.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';

class AnchorToEffectGame extends FlameGame with HasTappableComponents {
  @override
  Future<void> onLoad() async {
    final effect = AnchorToEffect(
      Anchor.bottomLeft,
      EffectController(speed: 1),
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
