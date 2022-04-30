import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../commons/ember.dart';

class KeyboardComponentExample extends FlameGame
    with HasKeyboardHandlerComponents {
  static const String description = '''
    Similar to the default Keyboard example, but shows a different implementation approach,
    which uses Flame's KeyboardComponent to handle input.
    Usage: Use A S D W to steer Ember.
  ''';

  static final Paint white = BasicPalette.white.paint();
  static const int speed = 200;

  late final Ember ember;
  final Vector2 velocity = Vector2(0, 0);

  @override
  Future<void> onLoad() async {
    ember = Ember(position: size / 2, size: Vector2.all(100));
    add(ember);

    add(
      KeyboardComponent(
        keyUp: {
          LogicalKeyboardKey.keyA: _stopX,
          LogicalKeyboardKey.keyD: _stopX,
          LogicalKeyboardKey.keyW: _stopY,
          LogicalKeyboardKey.keyS: _stopY,
        },
        keyDown: {
          LogicalKeyboardKey.keyA: () => _moveX(-1),
          LogicalKeyboardKey.keyD: () => _moveX(1),
          LogicalKeyboardKey.keyW: () => _moveY(-1),
          LogicalKeyboardKey.keyS: () => _moveY(1),
        },
      ),
    );
  }

  bool _stopY() {
    velocity.y = 0;
    return true;
  }

  bool _stopX() {
    velocity.x = 0;
    return true;
  }

  bool _moveX(double value) {
    velocity.x = value;
    return true;
  }

  bool _moveY(double value) {
    velocity.y = value;
    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final displacement = velocity * (speed * dt);
    ember.position.add(displacement);
  }
}
