import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

class OpacityEffectGame extends FlameGame with TapDetector {
  late final SpriteComponent sprite;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final flameSprite = await loadSprite('flame.png');
    add(
      sprite = SpriteComponent(
        sprite: flameSprite,
        position: Vector2.all(100),
        size: Vector2(149, 211),
      ),
    );

    add(
      SpriteComponent(
        sprite: flameSprite,
        position: Vector2(300, 100),
        size: Vector2(149, 211),
      )..add(
          OpacityEffect(
            opacity: 0,
            duration: 0.5,
            isInfinite: true,
            isAlternating: true,
          ),
        ),
    );
  }

  @override
  void onTap() {
    final opacity = sprite.paint.color.opacity;
    if (opacity == 1) {
      sprite.add(OpacityEffect.fadeOut());
    } else if (opacity == 0) {
      sprite.add(OpacityEffect.fadeIn());
    }
  }
}
