import 'package:examples/commons/ember.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class KeyboardExample extends FlameGame with KeyboardEvents {
  static const String description = '''
    Example showcasing how to act on keyboard events.
    It also briefly showcases how to create a game without the FlameGame.
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
  }

  @override
  void update(double dt) {
    super.update(dt);
    final displacement = velocity * (speed * dt);
    ember.position.add(displacement);
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final isKeyDown = event is RawKeyDownEvent;

    if (event.logicalKey == LogicalKeyboardKey.keyA) {
      velocity.x = isKeyDown ? -1 : 0;
    } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
      velocity.x = isKeyDown ? 1 : 0;
    } else if (event.logicalKey == LogicalKeyboardKey.keyW) {
      velocity.y = isKeyDown ? -1 : 0;
    } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
      velocity.y = isKeyDown ? 1 : 0;
    }

    return super.onKeyEvent(event, keysPressed);
  }
}
