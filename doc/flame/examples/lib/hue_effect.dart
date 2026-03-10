import 'dart:math';

import 'package:doc_flame_examples/ember.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';

class HueEffectExample extends FlameGame {
  @override
  Future<void> onLoad() async {
    final ember = EmberPlayer(
      position: size / 2,
      size: size / 4,
      onTap: (ember) {
        ember.add(
          HueEffect.by(
            2 * pi,
            EffectController(duration: 3),
          ),
        );
      },
    )..anchor = Anchor.center;

    add(ember);
  }
}
