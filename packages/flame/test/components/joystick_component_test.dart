import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/widgets.dart';
import 'package:test/test.dart';

class JoystickTester extends JoystickComponent {
  @override
  Vector2 delta = Vector2.zero();

  JoystickTester()
      : super(
          knob:
              JoystickElement.paint(BasicPalette.white.paint(), size: Vector2.all(5)),
          size: 20,
          margin: const EdgeInsets.only(left: 20, bottom: 20),
        );
}

class TestGame extends BaseGame with HasDraggableComponents {}

void main() {
  group('JoystickDirection tests', () {
    test('Can convert angle to JoystickDirection', () {
      final joystick = JoystickTester();
      final game = TestGame()..onResize(Vector2.all(200));
      game.add(joystick);
      game.update(0);

      expect(joystick.direction, JoystickDirection.idle);
      joystick.delta = Vector2(1.0, 0.0);
      expect(joystick.direction, JoystickDirection.right);
      joystick.delta = Vector2(0.0, 1.0);
      expect(joystick.direction, JoystickDirection.up);
      joystick.delta = Vector2(1.0, 1.0);
      expect(joystick.direction, JoystickDirection.upRight);
      joystick.delta = Vector2(-1.0, 1.0);
      expect(joystick.direction, JoystickDirection.upLeft);
      joystick.delta = Vector2(-1.0, 0.0);
      expect(joystick.direction, JoystickDirection.left);
      joystick.delta = Vector2(0.0, -1.0);
      expect(joystick.direction, JoystickDirection.down);
      joystick.delta = Vector2(1.0, -1.0);
      expect(joystick.direction, JoystickDirection.downRight);
      joystick.delta = Vector2(-1.0, -1.0);
      expect(joystick.direction, JoystickDirection.downLeft);
    });
  });
}
