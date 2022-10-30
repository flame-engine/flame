import 'package:examples/commons/ember.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

class OpacityEffectExample extends FlameGame with TapDetector {
  static const String description = '''
    In this example we show how the `OpacityEffect` can be used in two ways.
    The left Ember will constantly pulse in and out of opacity and the right
    flame will change opacity when you click the screen.
  ''';

  late final SpriteComponent sprite;

  @override
  Future<void> onLoad() async {
    final flameSprite = await loadSprite('flame.png');
    add(
      sprite = SpriteComponent(
        sprite: flameSprite,
        position: Vector2(300, 100),
        size: Vector2(149, 211),
      ),
    );

    add(
      Ember(
        position: Vector2(180, 230),
        size: Vector2.all(100),
      )..add(
          OpacityEffect.fadeOut(
            EffectController(
              duration: 1.5,
              reverseDuration: 1.5,
              infinite: true,
            ),
          ),
        ),
    );
  }

  @override
  void onTap() {
    final opacity = sprite.paint.color.opacity;
    if (opacity >= 0.5) {
      sprite.add(OpacityEffect.fadeOut(EffectController(duration: 1)));
    } else {
      sprite.add(OpacityEffect.fadeIn(EffectController(duration: 1)));
    }
  }
}
