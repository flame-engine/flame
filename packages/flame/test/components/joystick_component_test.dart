import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';
import 'package:flutter/widgets.dart';
import 'package:test/test.dart';

class TestGame extends FlameGame with HasDraggableComponents {}

void main() {
  group('JoystickDirection tests', () {
    test('Can convert angle to JoystickDirection', () {
      final joystick = JoystickComponent(
        knob: Circle(radius: 5.0).toComponent(),
        size: 20,
        margin: const EdgeInsets.only(left: 20, bottom: 20),
      );
      final game = TestGame()..onGameResize(Vector2.all(200));
      game.add(joystick);
      game.update(0);

      expect(joystick.direction, JoystickDirection.idle);
      joystick.delta = Vector2(1.0, 0.0);
      expect(joystick.direction, JoystickDirection.right);
      joystick.delta = Vector2(0.0, -1.0);
      expect(joystick.direction, JoystickDirection.up);
      joystick.delta = Vector2(1.0, -1.0);
      expect(joystick.direction, JoystickDirection.upRight);
      joystick.delta = Vector2(-1.0, -1.0);
      expect(joystick.direction, JoystickDirection.upLeft);
      joystick.delta = Vector2(-1.0, 0.0);
      expect(joystick.direction, JoystickDirection.left);
      joystick.delta = Vector2(0.0, 1.0);
      expect(joystick.direction, JoystickDirection.down);
      joystick.delta = Vector2(1.0, 1.0);
      expect(joystick.direction, JoystickDirection.downRight);
      joystick.delta = Vector2(-1.0, 1.0);
      expect(joystick.direction, JoystickDirection.downLeft);
    });
  });
}
