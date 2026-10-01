/// A game whose own logic runs in fixed steps, and input that waits for a
/// step to read it.
library;

import 'package:flame/components.dart'
    show CircleComponent, Component, JoystickComponent;
import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter3d_game/flutter3d_game.dart' show Bindings, InputSource;
import 'package:flutter3d_sim/flutter3d_sim.dart';
import 'package:flutter_test/flutter_test.dart';

final class _Stepped extends FlameGame with HasFixedStep {
  int steps = 0;

  @override
  void fixedUpdate(double step) => steps++;
}

final class _Ticker extends Component with FixedStepUpdate {
  int steps = 0;

  @override
  void fixedUpdate(double step) => steps++;
}

void main() {
  testWithGame<_Stepped>(
    'the game and its stepped components run once per step, not per frame',
    _Stepped.new,
    (game) async {
      final ticker = _Ticker();
      game.add(ticker);
      await game.ready();

      for (var i = 0; i < 4; i++) {
        game.update(1 / 120);
      }
      expect(game.steps, 2, reason: 'four half-steps are two steps');
      expect(ticker.steps, 2);

      game.update(1 / 30);
      expect(game.stepsThisFrame, 2);
      expect(ticker.steps, 4);
    },
  );

  testWithGame<_Stepped>(
    'a press in a frame with no step waits for the next step',
    _Stepped.new,
    (game) async {
      // Mutation: close the input step every frame, step or not.
      final input = FlameInputBridge(
        bindings: Bindings(<InputSource, GameAction>{}),
        inputState: InputState(),
      );
      game.add(input.stepEnd());
      await game.ready();
      const fire = GameAction('fire');

      input.inputState.press(fire);
      game.update(1 / 240);
      expect(game.stepsThisFrame, 0);
      expect(input.inputState.pressed(fire), isTrue, reason: 'still unread');

      game.update(1 / 60);
      expect(game.stepsThisFrame, 1);
      expect(input.inputState.pressed(fire), isFalse, reason: 'read, closed');
    },
  );

  testWithGame<_Stepped>(
    'a press is seen by one step of a frame that has three',
    _Stepped.new,
    (game) async {
      // Closed once a frame, all three steps saw the jump's press, and the
      // runner jumped three times.
      //
      // Mutation: close the input step at the end of the frame.
      final input = FlameInputBridge(
        bindings: Bindings(<InputSource, GameAction>{}),
        inputState: InputState(),
      );
      const jump = GameAction.jump;
      final reader = _Reads(input.inputState, jump);
      game.addAll(<Component>[input.stepEnd(), reader]);
      await game.ready();

      input.inputState.press(jump);
      game.update(3 / 60);
      expect(game.stepsThisFrame, 3);
      expect(reader.presses, 1);
      expect(input.inputState.held(jump), isTrue);
    },
  );

  testWithGame<_Stepped>(
    'the steps of a frame read the stick as it is that frame',
    _Stepped.new,
    (game) async {
      // The steps run before any component updates, and the stick was read
      // in its own component's update: a frame late.
      //
      // Mutation: read the stick in the feed's update.
      final input = FlameInputBridge(
        bindings: Bindings(<InputSource, GameAction>{}),
        inputState: InputState(),
      );
      final stick = JoystickComponent(
        knob: CircleComponent(radius: 10.0),
        background: CircleComponent(radius: 40.0),
      );
      final steers = _Steers(input.inputState);
      game.addAll(<Component>[
        stick,
        input.followJoystick(stick),
        steers,
      ]);
      await game.ready();

      stick.delta.setValues(stick.knobRadius, 0.0);
      game.update(1 / 60);
      expect(steers.seen, closeTo(1.0, 1e-9));
    },
  );

  testWithGame<_Stepped>(
    "physics and actors step in the game's steps, and draw by its alpha",
    _Stepped.new,
    (game) async {
      // Three clocks counted three sets of steps: the runner moved in the
      // game's, the crates in their own, never in turn.
      //
      // Mutation: step PhysicsStepComponent from its own FixedStep.
      final world = CollisionWorld();
      final dynamics = Dynamics(world: world);
      var physicsSteps = 0;
      final physics = PhysicsStepComponent(
        dynamics: dynamics,
        world: world,
        afterStep: () => physicsSteps++,
        step: FixedStep(stepSeconds: 1 / 30),
      );
      final actors = ActorSystemComponent(
        system: ActorSystem(world: world, random: GameRandom(1)),
        focus: Vector3.zero,
        step: FixedStep(stepSeconds: 1 / 30),
      );
      game.addAll(<Component>[physics, actors]);
      await game.ready();

      game.update(3 / 60 + 1 / 120);
      expect(physicsSteps, game.steps);
      expect(physics.alpha, game.alpha);
      expect(actors.alpha, game.alpha);
    },
  );
}

final class _Steers extends Component with FixedStepUpdate {
  _Steers(this.input);

  final InputState input;
  double seen = 0.0;

  @override
  void fixedUpdate(double step) => seen = input.moveAxis.x;
}

final class _Reads extends Component with FixedStepUpdate {
  _Reads(this.input, this.action);

  final InputState input;
  final GameAction action;
  int presses = 0;

  @override
  void fixedUpdate(double step) {
    if (input.pressed(action)) {
      presses++;
    }
  }
}
