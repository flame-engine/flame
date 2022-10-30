import 'package:doc_flame_examples/ember.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';

class SizeToEffectGame extends FlameGame with HasTappableComponents {
  bool reset = false;
  @override
  Future<void> onLoad() async {
    final ember = EmberPlayer(
      position: size / 2,
      size: Vector2(45, 40),
      onTap: (ember) {
        if (reset = !reset) {
          ember.add(
            SizeEffect.to(
              Vector2(90, 80),
              EffectController(duration: 0.75),
            ),
          );
        } else {
          ember.add(
            SizeEffect.to(
              Vector2(45, 40),
              EffectController(duration: 0.75),
            ),
          );
        }
      },
    )..anchor = Anchor.center;

    add(ember);
  }
}
