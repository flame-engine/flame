import 'package:doc_flame_examples/ember.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';

class ColorEffectExample extends FlameGame {
  bool reset = false;

  @override
  Future<void> onLoad() async {
    final ember = EmberPlayer(
      position: size / 2,
      size: size / 4,
      onTap: (ember) {
        if (reset = !reset) {
          ember.add(
            ColorEffect(
              const Color(0xFF00FF00),
              EffectController(duration: 1.5),
              opacityTo: 0.6,
            ),
          );
        } else {
          ember.add(
            ColorEffect(
              const Color(0xFF1039DB),
              EffectController(duration: 1.5),
              opacityTo: 0.6,
            ),
          );
        }
      },
    )..anchor = Anchor.center;

    add(ember);
  }
}
