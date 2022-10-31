import 'package:doc_flame_examples/flower.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';

class OpacityToEffectGame extends FlameGame with HasTappableComponents {
  bool reset = false;

  @override
  Future<void> onLoad() async {
    final flower = Flower(
      position: size / 2,
      size: 60,
      onTap: _onTap,
    )..anchor = Anchor.center;

    add(flower);
  }

  void _onTap(Flower flower) {
    if (reset = !reset) {
      flower.add(
        OpacityEffect.to(
          0.2,
          EffectController(duration: 0.75),
        ),
      );
    } else {
      flower.add(
        OpacityEffect.fadeIn(
          EffectController(duration: 0.75),
        ),
      );
    }
  }
}
