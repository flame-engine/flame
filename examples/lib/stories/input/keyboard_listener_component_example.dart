import 'package:examples/commons/ember.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';

class KeyboardListenerComponentExample extends FlameGame
    with HasKeyboardHandlerComponents {
  static const String description = '''
    Similar to the default Keyboard example, but shows a different
    implementation approach, which uses Flame's
    KeyboardListenerComponent to handle input.
    Usage: Use WASD to steer Ember.
  ''';

  static const int _speed = 200;

  late final Ember _ember;
  final Vector2 _direction = Vector2.zero();

  final Map<LogicalKeyboardKey, double> _keyWeights = {
    LogicalKeyboardKey.keyW: 0,
    LogicalKeyboardKey.keyA: 0,
    LogicalKeyboardKey.keyS: 0,
    LogicalKeyboardKey.keyD: 0,
  };

  @override
  Future<void> onLoad() async {
    _ember = Ember(position: size / 2, size: Vector2.all(100));
    add(_ember);

    add(
      KeyboardListenerComponent(
        keyUp: {
          LogicalKeyboardKey.keyA: (keys) =>
              _handleKey(LogicalKeyboardKey.keyA, false),
          LogicalKeyboardKey.keyD: (keys) =>
              _handleKey(LogicalKeyboardKey.keyD, false),
          LogicalKeyboardKey.keyW: (keys) =>
              _handleKey(LogicalKeyboardKey.keyW, false),
          LogicalKeyboardKey.keyS: (keys) =>
              _handleKey(LogicalKeyboardKey.keyS, false),
        },
        keyDown: {
          LogicalKeyboardKey.keyA: (keys) =>
              _handleKey(LogicalKeyboardKey.keyA, true),
          LogicalKeyboardKey.keyD: (keys) =>
              _handleKey(LogicalKeyboardKey.keyD, true),
          LogicalKeyboardKey.keyW: (keys) =>
              _handleKey(LogicalKeyboardKey.keyW, true),
          LogicalKeyboardKey.keyS: (keys) =>
              _handleKey(LogicalKeyboardKey.keyS, true),
        },
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    _direction
      ..setValues(xInput, yInput)
      ..normalize();

    final displacement = _direction * (_speed * dt);
    _ember.position.add(displacement);
  }

  bool _handleKey(LogicalKeyboardKey key, bool isDown) {
    _keyWeights[key] = isDown ? 1 : 0;
    return true;
  }

  double get xInput =>
      _keyWeights[LogicalKeyboardKey.keyD]! -
      _keyWeights[LogicalKeyboardKey.keyA]!;

  double get yInput =>
      _keyWeights[LogicalKeyboardKey.keyS]! -
      _keyWeights[LogicalKeyboardKey.keyW]!;
}
