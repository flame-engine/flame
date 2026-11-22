import 'package:examples/commons/ember.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';

class KeyboardExample() extends FlameGame with KeyboardCallbacks {
  static const String description = '''
    Example showcasing how to act on keyboard events.
    It also briefly showcases how to create a game without the FlameGame.
    Usage: Use WASD to steer Ember.
  ''';

  // Speed at which amber moves.
  static const double _speed = 200;

  // Direction in which amber is moving.
  final Vector2 _direction = Vector2.zero();

  @override
  Future<void> onLoad() async {
    add(
      Ember(
        key: ComponentKey.named('ember'),
        position: size / 2,
        size: Vector2.all(100),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    final ember = findByKeyName<Ember>('ember');
    final displacement = _direction.normalized() * _speed * dt;
    ember?.position.add(displacement);
  }

  @override
  void onKeyPress(KeyPressEvent event) => _steer(event.logicalKey, 1);

  @override
  void onKeyRelease(KeyReleaseEvent event) => _steer(event.logicalKey, -1);

  // A press adds the key's direction and its release takes it back off, so
  // holding opposite keys cancels out
  void _steer(LogicalKeyboardKey key, double sign) {
    if (key == LogicalKeyboardKey.keyA) {
      _direction.x -= sign;
    } else if (key == LogicalKeyboardKey.keyD) {
      _direction.x += sign;
    } else if (key == LogicalKeyboardKey.keyW) {
      _direction.y -= sign;
    } else if (key == LogicalKeyboardKey.keyS) {
      _direction.y += sign;
    }
  }
}
