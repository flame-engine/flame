import 'package:doc_flame_examples/flower.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';

class AnchorToEffectGame extends FlameGame with HasTappableComponents {
  @override
  Future<void> onLoad() async {
    final flower = Flower(
      size: 60,
      position: canvasSize / 2,
      onTap: (flower) {
        if (flower.anchor == Anchor.center) {
          flower.add(
            AnchorToEffect(
              Anchor.bottomLeft,
              EffectController(speed: 1),
            ),
          );
        } else {
          flower.add(
            AnchorToEffect(
              Anchor.center,
              EffectController(speed: 1),
            ),
          );
        }
      },
    );
    add(flower);
  }
}
