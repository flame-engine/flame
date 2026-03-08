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
        position: Vector2(size.x / 2, size.y / 2),
        size: Vector2.all(100),
      )..add(
        HueEffect(
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
