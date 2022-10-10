import 'package:doc_flame_examples/ember.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';

class OpacityByEffectGame extends FlameGame with HasTappableComponents {
  bool reset = false;
  @override
  Future<void> onLoad() async {
    final ember = EmberPlayer(
      position: size / 2,
      size: size / 4,
      onTap: (ember) {
        if (reset = !reset) {
          ember.add(
            OpacityEffect.by(
              0.9,
              EffectController(duration: 0.75),
            ),
          );
        } else {
          ember.add(
            OpacityEffect.by(
              -0.9,
              EffectController(duration: 0.75),
            ),
          );
        }
      },
    )..anchor = Anchor.center;

    add(ember);
  }
}
