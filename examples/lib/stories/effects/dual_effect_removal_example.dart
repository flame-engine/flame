import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class DualEffectRemovalExample extends FlameGame with TapDetector {
  static const String description = '''
    In this example we show how a dual effect can be used and removed.
    To remove an effect, tap anywhere on the screen and the first tap will
    remove the OpacityEffect and the second tap removes the ColorEffect.
    In this example, when an effect is removed the component is reset to
    the state (the part of the state that was affected by the running effect)
    that it had before the effect started running.
  ''';

  late ColorEffect colorEffect;
  late OpacityEffect opacityEffect;

  @override
  Future<void> onLoad() async {
    final mySprite = SpriteComponent(
      sprite: await loadSprite('flame.png'),
      position: Vector2(50, 50),
    );

    add(mySprite);

    final colorController = EffectController(
      duration: 2,
      reverseDuration: 2,
      infinite: true,
    );
    colorEffect = ColorEffect(
      Colors.blue,
      const Offset(0.0, 0.8),
      colorController,
    );
    mySprite.add(colorEffect);

    final opacityController = EffectController(
      duration: 1,
      reverseDuration: 1,
      infinite: true,
    );
    opacityEffect = OpacityEffect.fadeOut(opacityController);
    mySprite.add(opacityEffect);
  }

  @override
  void onTap() {
    // apply(0) sends the animation to its initial starting state.
    // If this isn't called, the effect would be removed and leave the
    // component at its current state.
    // Hence when you want an effect to be removed and the component to go
    // back to how it looked prior to the effect, you must call apply(0) before
    // you call removeFromParent().
    if (opacityEffect.isMounted) {
      opacityEffect.apply(0);
      opacityEffect.removeFromParent();
    } else if (colorEffect.isMounted) {
      colorEffect.apply(0);
      colorEffect.removeFromParent();
    }
  }
}
