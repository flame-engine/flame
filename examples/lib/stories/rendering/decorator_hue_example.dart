import 'dart:math';

import 'package:examples/commons/ember.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/rendering.dart';

class DecoratorHueExample extends FlameGame with TapCallbacks {
  static const String description = '''
This example demonstrates the usage of `HueDecorator` to shift the
colors of a component.

Basic `HueDecorator` shifting the hue of an Ember component.

Click to cycle through hue shifts.
''';

  late final HueDecorator decorator;
  int step = 0;

  @override
  Future<void> onLoad() async {
    decorator = HueDecorator();
    world.add(
      PositionComponent(
        size: Vector2(150, 120),
        anchor: Anchor.center,
        children: [
          Ember(
            size: Vector2.all(80),
            position: Vector2(75, 40),
          ),
          TextComponent(
            text: 'HueDecorator',
            position: Vector2(75, 100),
            anchor: Anchor.center,
          ),
        ],
      )..decorator.addLast(decorator),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    step++;
    final hues = [0.0, pi / 4, pi / 2, pi, 0.0];
    final hue = hues[step % hues.length];
    decorator.hue = hue;
  }
}
