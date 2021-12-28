import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/widgets.dart';
import 'package:test/test.dart';

class _GameHasDraggables extends FlameGame with HasDraggables {}

void main() {
  final withDraggables = FlameTester(() => _GameHasDraggables());

  group('JoystickDirection tests', () {
    withDraggables.test('can convert angle to JoystickDirection', (game) async {
      final joystick = JoystickComponent(
        knob: CircleComponent(radius: 5.0),
        size: 20,
        margin: const EdgeInsets.only(left: 20, bottom: 20),
      );
      await game.ensureAdd(joystick);

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
    withDraggables.test(
      'knob should stay on correct side when the total delta is larger than '
      'the size and then the knob is moved slightly back again',
      (game) async {
        final joystick = JoystickComponent(
          knob: CircleComponent(radius: 5.0),
          size: 20,
          margin: const EdgeInsets.only(left: 20, top: 20),
        );
        await game.add(joystick);
        game.update(0);
        expect(joystick.knob!.position, closeToVector(10, 10));
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
        expect(joystick.knob!.position, closeToVector(20, 10));
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
        expect(joystick.knob!.position, closeToVector(20, 10));
      },
    );
  });
}
