/// The input step closed for the game, a pointer followed as an aim and a
/// tap as an action, and a swipe as a press.
library;

import 'package:flame/components.dart'
    show CircleComponent, Component, JoystickComponent;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter3d_game/flutter3d_game.dart' show Bindings, InputSource;
import 'package:flutter3d_sim/flutter3d_sim.dart';
import 'package:flutter_test/flutter_test.dart';

const GameAction _fire = GameAction('fire');
const GameAction _hop = GameAction('hop');

FlameInputBridge _bridge() => FlameInputBridge(
  bindings: Bindings(<InputSource, GameAction>{}),
  inputState: InputState(),
);

void main() {
  testWithGame<FlameGame>(
    'the step is closed at the end of the frame, after everything read it',
    FlameGame.new,
    (game) async {
      // A game that forgot to close the step saw a key pressed once as
      // pressed on every frame after.
      //
      // Mutation: never call endStep.
      final input = _bridge();
      var seen = 0;
      game.addAll(<Component>[
        input.stepEnd(),
        _Reader(() {
          if (input.inputState.pressed(_fire)) {
            seen++;
          }
        }),
      ]);
      await game.ready();

      input.inputState.press(_fire);
      game.update(1 / 60);
      game.update(1 / 60);
      expect(seen, 1, reason: 'pressed once, read as pressed once');
      expect(input.inputState.held(_fire), isTrue);
    },
  );

  testWithGame<FlameGame>(
    'the pointer is an aim, and a tap holds an action while it is down',
    FlameGame.new,
    (game) async {
      final input = _bridge();
      final pointer = input.pointer(press: _fire);
      game.add(pointer);
      await game.ready();
      expect(pointer.aim, isNull);

      pointer.onTapDown(
        TapDownEvent(
          1,
          game,
          TapDownDetails(
            globalPosition: const Offset(120.0, 80.0),
            localPosition: const Offset(120.0, 80.0),
          ),
        ),
      );
      expect(pointer.aim, Vector2(120.0, 80.0));
      expect(input.inputState.held(_fire), isTrue);

      pointer.onTapUp(
        TapUpEvent(
          1,
          game,
          TapUpDetails(
            kind: PointerDeviceKind.touch,
            globalPosition: const Offset(120.0, 80.0),
            localPosition: const Offset(120.0, 80.0),
          ),
        ),
      );
      expect(input.inputState.held(_fire), isFalse);
    },
  );

  testWithGame<FlameGame>(
    'a finger that slides to aim keeps the action held until it lifts',
    FlameGame.new,
    (game) async {
      // Flutter gives up on a tap once the finger moves, and firing while
      // dragging to aim stopped the moment the aim moved.
      //
      // Mutation: let go on a tap's cancel.
      final input = _bridge();
      final pointer = input.pointer(press: _fire);
      game.add(pointer);
      await game.ready();

      pointer
        ..onTapDown(
          TapDownEvent(
            1,
            game,
            TapDownDetails(globalPosition: const Offset(100.0, 100.0)),
          ),
        )
        ..onTapCancel(TapCancelEvent(1))
        ..onDragStart(
          DragStartEvent(
            1,
            game,
            DragStartDetails(globalPosition: const Offset(100.0, 100.0)),
          ),
        );
      await Future<void>.delayed(Duration.zero);
      expect(input.inputState.held(_fire), isTrue, reason: 'still down');

      pointer.onDragEnd(DragEndEvent(1, DragEndDetails()));
      expect(input.inputState.held(_fire), isFalse);
    },
  );

  testWithGame<FlameGame>(
    "a touch stick at rest leaves a pad's stick alone",
    FlameGame.new,
    (game) async {
      // Written every frame, a resting touch stick wrote zero over the pad.
      //
      // Mutation: write the deflection every frame.
      final input = _bridge();
      final stick = JoystickComponent(
        knob: CircleComponent(radius: 10.0),
        background: CircleComponent(radius: 40.0),
        position: Vector2(100.0, 100.0),
      );
      game.addAll(<Component>[stick, input.followJoystick(stick)]);
      await game.ready();

      input.inputState.setStickAxis(0.5, 0.0);
      game.update(1 / 60);
      expect(input.inputState.moveAxis.x, closeTo(0.5, 1e-9));
    },
  );

  testWithGame<FlameGame>(
    'a swipe presses the action of its direction, once',
    FlameGame.new,
    (game) async {
      final input = _bridge();
      final swipes = input.swipes(up: _hop);
      game.add(swipes);
      await game.ready();

      void drag(Offset by) {
        swipes.onDragStart(
          DragStartEvent(
            1,
            game,
            DragStartDetails(globalPosition: const Offset(200.0, 300.0)),
          ),
        );
        swipes.onDragUpdate(
          DragUpdateEvent(
            1,
            game,
            DragUpdateDetails(
              globalPosition: const Offset(200.0, 300.0) + by,
              delta: by,
            ),
          ),
        );
        swipes.onDragEnd(DragEndEvent(1, DragEndDetails()));
      }

      drag(const Offset(5.0, -10.0));
      expect(input.inputState.pressed(_hop), isFalse, reason: 'too short');

      drag(const Offset(8.0, -90.0));
      expect(input.inputState.pressed(_hop), isTrue);
      expect(
        input.inputState.held(_hop),
        isFalse,
        reason: 'a press, not a hold',
      );
    },
  );
}

final class _Reader extends Component {
  _Reader(this.read);

  final void Function() read;

  @override
  void update(double dt) => read();
}
