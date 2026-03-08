import 'dart:math';

import 'package:examples/commons/ember.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/rendering.dart';

class HueDecoratorExample extends FlameGame with TapCallbacks {
  static const String description = '''
    In this example we show how the `HueDecorator` can be used.
    Click anywhere to cycle through different hue shifts on Ember.
  ''';

  late final Ember ember;
  int step = 0;

  @override
  Future<void> onLoad() async {
    add(
      ember = Ember(
        position: size / 2,
        size: Vector2.all(100),
      )..decorator = HueDecorator(),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    step++;
    final decorator = ember.decorator as HueDecorator;
    if (step == 1) {
      decorator.hue = pi / 4;
    } else if (step == 2) {
      decorator.hue = pi / 2;
    } else if (step == 3) {
      decorator.hue = pi;
    } else {
      decorator.hue = 0;
      step = 0;
    }
  }
}
