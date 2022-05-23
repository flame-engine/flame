import 'package:examples/commons/ember.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class KeyboardListenerComponentExample extends FlameGame
    with HasKeyboardHandlerComponents {
  static const String description = '''
    Similar to the default Keyboard example, but shows a different
    implementation approach, which uses Flame's
    KeyboardListenerComponent to handle input.
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
      KeyboardListenerComponent(
        keyUp: {
          LogicalKeyboardKey.keyA: (keys) => _handleKey(
                false,
                LogicalKeyboardKey.keyA,
                keys,
              ),
          LogicalKeyboardKey.keyD: (keys) => _handleKey(
                false,
                LogicalKeyboardKey.keyD,
                keys,
              ),
          LogicalKeyboardKey.keyW: (keys) => _handleKey(
                false,
                LogicalKeyboardKey.keyW,
                keys,
              ),
          LogicalKeyboardKey.keyS: (keys) => _handleKey(
                false,
                LogicalKeyboardKey.keyS,
                keys,
              ),
        },
        keyDown: {
          LogicalKeyboardKey.keyA: (keys) => _handleKey(
                true,
                LogicalKeyboardKey.keyA,
                keys,
              ),
          LogicalKeyboardKey.keyD: (keys) => _handleKey(
                true,
                LogicalKeyboardKey.keyD,
                keys,
              ),
          LogicalKeyboardKey.keyW: (keys) => _handleKey(
                true,
                LogicalKeyboardKey.keyW,
                keys,
              ),
          LogicalKeyboardKey.keyS: (keys) => _handleKey(
                true,
                LogicalKeyboardKey.keyS,
                keys,
              ),
        },
      ),
    );
  }

  bool _handleKey(
    bool isDown,
    LogicalKeyboardKey key,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    const w = LogicalKeyboardKey.keyW;
    const a = LogicalKeyboardKey.keyA;
    const s = LogicalKeyboardKey.keyS;
    const d = LogicalKeyboardKey.keyD;

    if (key == w) {
      if (isDown) {
        velocity.y = -1;
      } else if (keysPressed.contains(s)) {
        velocity.y = 1;
      } else {
        velocity.y = 0;
      }
    } else if (key == s) {
      if (isDown) {
        velocity.y = 1;
      } else if (keysPressed.contains(w)) {
        velocity.y = -1;
      } else {
        velocity.y = 0;
      }
    } else if (key == a) {
      if (isDown) {
        velocity.x = -1;
      } else if (keysPressed.contains(d)) {
        velocity.x = 1;
      } else {
        velocity.x = 0;
      }
    } else if (key == d) {
      if (isDown) {
        velocity.x = 1;
      } else if (keysPressed.contains(a)) {
        velocity.x = -1;
      } else {
        velocity.x = 0;
      }
    }

    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final displacement = velocity * (speed * dt);
    ember.position.add(displacement);
  }
}
