import 'package:examples/commons/ember.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class KeyboardExample extends FlameGame with KeyboardEvents {
  static const String description = '''
    Example showcasing how to act on keyboard events.
    It also briefly showcases how to create a game without the FlameGame.
    Usage: Use WASD to steer Ember.
  ''';

  // Speed at which amber moves.
  static const double _speed = 200;

  // Direction in which amber is moving.
  final Vector2 _direction = Vector2.zero();

  late final Ember _ember;

  @override
  Future<void> onLoad() async {
    _ember = Ember(position: size / 2, size: Vector2.all(100));
    add(_ember);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final displacement = _direction.normalized() * _speed * dt;
    _ember.position.add(displacement);
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final isKeyDown = event is RawKeyDownEvent;

    // Avoiding repeat event as we are interested only in
    // key up and key down event.
    if (!event.repeat) {
      if (event.logicalKey == LogicalKeyboardKey.keyA) {
        _direction.x += isKeyDown ? -1 : 1;
      } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
        _direction.x += isKeyDown ? 1 : -1;
      } else if (event.logicalKey == LogicalKeyboardKey.keyW) {
        _direction.y += isKeyDown ? -1 : 1;
      } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
        _direction.y += isKeyDown ? 1 : -1;
      }
    }

    return super.onKeyEvent(event, keysPressed);
  }
}
