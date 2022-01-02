import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import '../../commons/ember.dart';

class DualEffectRemovalExample extends FlameGame with TapDetector {
  static const String description = '''
    In this example we show how a dual effect can be used and removed.
    To remove an effect just tap anywhere on the screen.
    The 1st tap will remove the OpacityEffect and the 2nd tap removes the ColorEffect.
  ''';

  late final SpriteComponent mySprite;
  late  ColorEffect fx;
  late OpacityEffect opfx;
  int count = 0;
  late EffectController controller1;
  late EffectController controller2;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    Sprite flameSprite = await loadSprite('flame.png');
    Vector2 spriteSize = flameSprite.srcSize;
    Vector2 spritePostion = Vector2(50,50);
    mySprite = SpriteComponent(sprite: flameSprite,position: spritePostion,size: spriteSize);
    add(mySprite);
    
    controller1 = EffectController(duration: 2,reverseDuration: 2,infinite: true,);
    fx = ColorEffect(Colors.blue, const Offset(0.0, 0.8,), controller1 );
    mySprite.add(fx);

    controller2 = EffectController(duration: 1,reverseDuration: 1,infinite: true,);
    opfx = OpacityEffect.fadeOut(controller2);
    mySprite.add(opfx);
  }
  
///apply(0) sends the animation to its initial starting state. if this isnt called, the fx could be removed at its presently animating state, and then that look
/// of the sprite cant be changed. Hence when you want an effect to be removed and the sprite must go back to exactly how it looked, prior to the effect, you must call apply(0)
///befor you call on the removeFromParent()
  @override
  void onTap() {
    count++;
    if (count > 1) {
      fx.apply(0);
      fx.removeFromParent();
    }
    else{
      opfx.apply(0);
      opfx.removeFromParent();
    }
  }



}
