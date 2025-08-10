import 'package:flame/components.dart';
import 'package:flame/src/events/flame_game_mixins/multi_drag_dispatcher.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/widgets.dart';
import 'package:test/test.dart';

void main() {
  group('JoystickDirection tests', () {
    testWithFlameGame(
      'can convert angle to JoystickDirection',
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

    testWithFlameGame(
      'properly re-positions onGameSize',
      (game) async {
        game.onGameResize(Vector2(100, 200));
        final joystick = JoystickComponent(
          knob: CircleComponent(radius: 5.0),
          size: 20,
          margin: const EdgeInsets.only(left: 20, bottom: 20),
        );
        joystick.mounted.then((_) => game.onGameResize(Vector2(200, 100)));
        await game.ensureAdd(joystick);
        expect(joystick.position, Vector2(30, 70));
      },
    );

    testWithFlameGame(
      'properly re-positions with FixedResolutionViewport',
      (game) async {
        game.camera = CameraComponent.withFixedResolution(
          width: 100,
          height: 200,
        );
        game.onGameResize(Vector2(100, 200));
        final joystick = JoystickComponent(
          knob: CircleComponent(radius: 5.0),
          size: 20,
          margin: const EdgeInsets.only(left: 20, bottom: 20),
        );
        await game.camera.viewport.ensureAdd(joystick);
        expect(joystick.position, Vector2(30, 170));
        game.onGameResize(Vector2(200, 100));
        expect(joystick.position, Vector2(30, 170));
      },
    );
  });

  group('Joystick input tests', () {
    testWithFlameGame(
      'knob should stay on correct side when the total delta is larger than '
      'the size and then the knob is moved slightly back again',
      (game) async {
        final joystick = JoystickComponent(
          knob: CircleComponent(radius: 5.0),
          size: 20,
          margin: const EdgeInsets.only(left: 20, top: 20),
        );
        await game.add(joystick);
        await game.ready();
        expect(joystick.knob!.position, closeToVector(Vector2(10, 10)));
        final dragDispatcher = game.firstChild<MultiDragDispatcher>()!;
        // Start dragging the joystick
        dragDispatcher.handleDragStart(
          1,
          DragStartDetails(
            localPosition: const Offset(20, 20),
            globalPosition: const Offset(20, 20),
          ),
        );
        game.update(0);
        // Drag the knob outside of the size of the joystick in X-axis
        dragDispatcher.handleDragUpdate(
          1,
          DragUpdateDetails(
            localPosition: const Offset(60, 20),
            globalPosition: const Offset(60, 20),
            delta: const Offset(40, 0),
          ),
        );
        game.update(0);
        expect(joystick.knob!.position, closeToVector(Vector2(20, 10)));
        // Drag the knob back towards it's base position
        dragDispatcher.handleDragUpdate(
          1,
          DragUpdateDetails(
            localPosition: const Offset(40, 20),
            globalPosition: const Offset(40, 20),
            delta: const Offset(-20, 0),
          ),
        );
        game.update(0);
        expect(joystick.knob!.position, closeToVector(Vector2(20, 10)));
      },
    );
  });
}
