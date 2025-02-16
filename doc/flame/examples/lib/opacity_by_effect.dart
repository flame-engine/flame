import 'package:doc_flame_examples/ember.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';

class OpacityByEffectGame extends FlameGame {
  bool reset = false;

  @override
  Future<void> onLoad() async {
    final ember = EmberPlayer(
      position: size / 2,
      size: size / 4,
      onTap: (ember) {
        ember.add(
          OpacityEffect.by(
            reset ? 0.9 : -0.9,
            EffectController(duration: 0.75),
          ),
        );
        reset = !reset;
      },
    )..anchor = Anchor.center;

    add(ember);
  }
}
