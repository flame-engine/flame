import 'package:doc_flame_examples/ember.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';

class OpacityGame extends FlameGame with HasTappableComponents {
  bool reset = false;
  @override
  Future<void> onLoad() async {
    final ember = EmberPlayer(
      position: canvasSize / 3,
      size: size / 4,
      onTap: (ember) {
        if (reset = !reset) {
          ember.add(OpacityEffect.to(0.5, EffectController(duration: 0.75)));
        } else {
          ember.add(OpacityEffect.to(1.0, EffectController(duration: 0.75)));
        }
      },
    );

    add(ember);
  }
}
