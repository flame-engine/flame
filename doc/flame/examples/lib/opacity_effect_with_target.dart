import 'package:doc_flame_examples/flower.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';

class OpacityEffectWithTargetGame extends FlameGame with HasTappableComponents {
  bool reset = false;

  // This reference needs to be stored because every new instance of
  // OpacityProvider caches the opacity ratios at the time on creation.
  late OpacityProvider _borderOpacityProvider;

  @override
  Future<void> onLoad() async {
    final flower = Flower(
      position: size / 2,
      size: 60,
      onTap: _onTap,
    )..anchor = Anchor.center;

    _borderOpacityProvider = flower.opacityProviderOfList(
      paintIds: const [FlowerPaint.paintId1, FlowerPaint.paintId2],
    );

    add(flower);
  }

  void _onTap(Flower flower) {
    if (reset = !reset) {
      flower.add(
        OpacityEffect.to(
          0.2,
          EffectController(duration: 0.75),
          target: _borderOpacityProvider,
        ),
      );
    } else {
      flower.add(
        OpacityEffect.fadeIn(
          EffectController(duration: 0.75),
          target: _borderOpacityProvider,
        ),
      );
    }
  }
}
