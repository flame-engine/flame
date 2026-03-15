import 'dart:math';

import 'package:examples/commons/ember.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';

class HueEffectExample extends FlameGame {
  static const String description = '''
In this example we show how the `HueEffect` can be used.
Ember will shift its hue over time.
  ''';

  @override
  Future<void> onLoad() async {
    add(
      Ember(
        position: size / 2,
        size: Vector2.all(100),
      )..add(
        HueEffect.by(
          2 * pi,
          EffectController(
            duration: 3,
            infinite: true,
          ),
        ),
      ),
    );
  }
}
