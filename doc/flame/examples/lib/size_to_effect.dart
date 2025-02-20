import 'package:doc_flame_examples/ember.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';

class SizeToEffectGame extends FlameGame {
  bool reset = false;
  @override
  Future<void> onLoad() async {
    final ember = EmberPlayer(
      position: size / 2,
      size: Vector2(45, 40),
      onTap: (ember) {
        ember.add(
          SizeEffect.to(
            reset ? Vector2(45, 40) : Vector2(90, 80),
            EffectController(duration: 0.75),
          ),
        );
        reset = !reset;
      },
    )..anchor = Anchor.center;

    add(ember);
  }
}
