import 'package:doc_flame_examples/flower.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';

class AnchorToEffectGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    final flower = Flower(
      size: 60,
      position: canvasSize / 2,
      onTap: (flower) {
        flower.add(
          AnchorToEffect(
            flower.anchor == Anchor.center ? Anchor.bottomLeft : Anchor.center,
            EffectController(speed: 1),
          ),
        );
      },
    );
    add(flower);
  }
}
