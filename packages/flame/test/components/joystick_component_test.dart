import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/widgets.dart';
import 'package:test/test.dart';

class _GameHasDraggables extends FlameGame with HasDraggables {}

void main() {
  group('JoystickDirection tests', () {
    testWithGame<_GameHasDraggables>(
      'can convert angle to JoystickDirection',
      _GameHasDraggables.new,
      (game) async {
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
      },
    );

    testWithGame<_GameHasDraggables>(
      'properly re-positions onGameSize',
      _GameHasDraggables.new,
      (game) async {
        game.onGameResize(Vector2(100, 200));
        final joystick = JoystickComponent(
          knob: CircleComponent(radius: 5.0),
          size: 20,
          margin: const EdgeInsets.only(left: 20, bottom: 20),
        );
        joystick.loaded.then((_) => game.onGameResize(Vector2(200, 100)));
        await game.ensureAdd(joystick);
        expect(joystick.position, Vector2(30, 70));
      },
    );
  });

  group('Joystick input tests', () {
    testWithGame<_GameHasDraggables>(
      'knob should stay on correct side when the total delta is larger than '
      'the size and then the knob is moved slightly back again',
      _GameHasDraggables.new,
      (game) async {
        final joystick = JoystickComponent(
          knob: CircleComponent(radius: 5.0),
          size: 20,
          margin: const EdgeInsets.only(left: 20, top: 20),
        );
        await game.add(joystick);
        await game.ready();
        expect(joystick.knob!.position, closeToVector(Vector2(10, 10)));
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
        expect(joystick.knob!.position, closeToVector(Vector2(20, 10)));
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
        expect(joystick.knob!.position, closeToVector(Vector2(20, 10)));
      },
    );
  });
}
