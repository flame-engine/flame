import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/widgets.dart';
import 'package:test/test.dart';

class TestGame extends FlameGame with HasDraggableComponents {}

final testGame = FlameTester(() => TestGame());

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
      joystick.delta.setValues(1.0, 0.0);
      expect(joystick.direction, JoystickDirection.right);
      joystick.delta.setValues(0.0, -1.0);
      expect(joystick.direction, JoystickDirection.up);
      joystick.delta.setValues(1.0, -1.0);
      expect(joystick.direction, JoystickDirection.upRight);
      joystick.delta.setValues(-1.0, -1.0);
      expect(joystick.direction, JoystickDirection.upLeft);
      joystick.delta.setValues(-1.0, 0.0);
      expect(joystick.direction, JoystickDirection.left);
      joystick.delta.setValues(0.0, 1.0);
      expect(joystick.direction, JoystickDirection.down);
      joystick.delta.setValues(1.0, 1.0);
      expect(joystick.direction, JoystickDirection.downRight);
      joystick.delta.setValues(-1.0, 1.0);
      expect(joystick.direction, JoystickDirection.downLeft);
    });
  });

  group('Joystick input tests', () {
    testGame.test(
      'knob should stay on correct side when the total delta is larger than the size and then the knob is moved slightly back again',
      (game) async {
        final joystick = JoystickComponent(
          knob: Circle(radius: 5.0).toComponent(),
          size: 20,
          margin: const EdgeInsets.only(left: 20, top: 20),
        );
        await game.add(joystick);
        game.update(0);
        expectVector2(joystick.knob.position, Vector2(10, 10));
        // Start dragging the joystick
        game.onDragStart(
          1,
          DragStartInfo.fromDetails(
            game,
            DragStartDetails(
              localPosition: const Offset(20, 20),
              globalPosition: const Offset(20, 20),
            ),
          ),
        );
        game.update(0);
        // Drag the knob outside of the size of the joystick in X-axis
        game.onDragUpdate(
          1,
          DragUpdateInfo.fromDetails(
            game,
            DragUpdateDetails(
              localPosition: const Offset(60, 20),
              globalPosition: const Offset(60, 20),
              delta: const Offset(40, 0),
            ),
          ),
        );
        game.update(0);
        expectVector2(joystick.knob.position, Vector2(20, 10));
        // Drag the knob back towards it's base position
        game.onDragUpdate(
          1,
          DragUpdateInfo.fromDetails(
            game,
            DragUpdateDetails(
              localPosition: const Offset(40, 20),
              globalPosition: const Offset(40, 20),
              delta: const Offset(-20, 0),
            ),
          ),
        );
        game.update(0);
        expectVector2(joystick.knob.position, Vector2(20, 10));
      },
    );
  });
}
