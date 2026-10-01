import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_flutter3d/src/host/step_clock.dart';
import 'package:flutter3d_sim/flutter3d_sim.dart' show FixedStep;

/// A component whose game logic runs in the game's fixed steps rather than
/// in its frames. See [HasFixedStep].
mixin FixedStepUpdate on Component {
  /// Moves this component on by one step of [step] seconds.
  void fixedUpdate(double step);

  /// Coming, going and being reordered are what change the game's list of
  /// who steps, and each says so: the game walks its tree only then.
  @override
  void onMount() {
    super.onMount();
    _changedStepping(this);
  }

  @override
  void onRemove() {
    _changedStepping(this);
    super.onRemove();
  }

  @override
  set priority(int value) {
    super.priority = value;
    _changedStepping(this);
  }
}

void _changedStepping(Component component) {
  final game = component.findGame();
  if (game is HasFixedStep) {
    game._stepping = null;
  }
}

/// A Flame game whose logic runs in fixed steps: the same second of play
/// comes out the same at any frame rate.
///
/// **Flame's `update` is a frame, and a frame is whatever it took.** A jet
/// flown by `speed * dt` travels the same distance at any frame rate only
/// until something is decided along the way: a turn read from input, a
/// fuel tank emptied, a collision caught one frame and missed the next. A
/// replay recorded at 60 frames a second and played at 144 came out
/// differently, and so did a run on a machine that stalled. The physics and
/// the actors already step in fixed steps; this is the same for the game's
/// own logic.
///
/// Each frame, the time is spent in whole steps of [fixedStep]'s size, at
/// most its `maxStepsPerFrame` after a stall. Each step calls
/// [fixedUpdate] on the game and then on every [FixedStepUpdate] component
/// in it, in tree order. Flame's own `update` still runs once a frame after
/// them, for what should follow the screen rather than the simulation: a
/// camera, an animation, a sound. [alpha] is how far the frame is past the
/// last step.
///
/// **Input is closed after every step, not every frame.** A press is seen by
/// exactly one step: `FlameInputBridge.stepEnd` closes the input step from
/// [afterEachStep]. Closed once a frame, a frame of three steps showed a
/// jump's press to all three, and a frame of none closed it unseen.
///
/// **One clock for everything that steps.** `PhysicsStepComponent` and
/// `ActorSystemComponent` in a game with this step in its steps, in tree
/// order, rather than counting their own: the runner and the crates it
/// pushes move in turn, step by step, and [alpha] is the one fraction every
/// drawing between two steps uses.
///
/// Flame's collision detection still runs once a frame.
///
/// Generic over the game's world, as `HasFlutter3d` is, so a game whose
/// world has a type of its own can step too.
///
/// **A [StepClock].** A game that steps its own simulation in [fixedUpdate] —
/// a genre's `step`, moving its bodies and actors itself — hands itself to
/// the components that draw them, and they are told to keep their places
/// before each step, ahead of the game's own logic, then drawn [alpha] of the
/// way on.
mixin HasFixedStep<W extends World> on FlameGame<W> implements StepClock {
  /// How the frame's time is cut: a sixtieth of a second unless replaced.
  FixedStep fixedStep = FixedStep();

  int _steps = 0;

  /// How many steps this frame ran.
  int get stepsThisFrame => _steps;

  /// How far this frame is past the last step, from 0 up to 1.
  @override
  double get alpha => fixedStep.alpha;

  final Set<StepFollower> _followers = <StepFollower>{};

  @override
  void follow(StepFollower follower) => _followers.add(follower);

  @override
  void unfollow(StepFollower follower) => _followers.remove(follower);

  final List<void Function()> _stepStarts = <void Function()>[];

  /// Calls [start] at the start of every step, before the game's own
  /// [fixedUpdate]: where a step's reports are forgotten, so that what the
  /// game does in its logic is still there to be read after the step.
  ///
  /// `ActorSystemComponent` opens its system's step here. It used to open it
  /// just before stepping the actors, after the game's own logic had run: a
  /// shot fired there killed a monster, and the death was wiped before
  /// anything could read it.
  void beforeEachStep(void Function() start) => _stepStarts.add(start);

  /// Stops calling [start].
  void removeBeforeEachStep(void Function() start) => _stepStarts.remove(start);

  /// The game's own logic for one step of [step] seconds.
  void fixedUpdate(double step) {}

  final List<void Function()> _stepEnds = <void Function()>[];

  /// Calls [end] after every step, once everything in it has run: where the
  /// input step is closed.
  void afterEachStep(void Function() end) => _stepEnds.add(end);

  /// Stops calling [end].
  void removeAfterEachStep(void Function() end) => _stepEnds.remove(end);

  final List<void Function()> _frameStarts = <void Function()>[];

  /// Calls [start] once a frame, before its steps: where what the steps
  /// read is gathered, a touch stick's deflection say.
  ///
  /// **The steps run before any component updates.** A stick read in its
  /// own component's update, the way a frame-by-frame game reads it, reached
  /// the steps a frame after it was read, two after the finger moved.
  void beforeSteps(void Function() start) => _frameStarts.add(start);

  /// Stops calling [start].
  void removeBeforeSteps(void Function() start) => _frameStarts.remove(start);

  /// The components that step, in tree order: walked out of the tree only
  /// when one of them came, went or moved, and kept until then.
  ///
  /// **Not once a frame.** Every frame walked every component in the game to
  /// find the handful that step, which in a game with a horde is hundreds of
  /// components and a list, sixty times a second, for an answer that had not
  /// changed.
  List<FixedStepUpdate>? _stepping;

  /// How long the frame being stepped is, in seconds: set before [beforeSteps]
  /// runs, so what is read there — a stick's turn rate — is read against this
  /// frame's time rather than the last one's.
  double get frameSeconds => _frameSeconds;
  double _frameSeconds = 0.0;

  /// A component added in a step is mounted with the frame, and joins the
  /// steps after it.
  @override
  void update(double dt) {
    _frameSeconds = dt;
    for (final start in List<void Function()>.of(_frameStarts)) {
      start();
    }
    _steps = fixedStep.advance(dt);
    if (_steps > 0) {
      final stepping = _stepping ??= descendants()
          .whereType<FixedStepUpdate>()
          .toList(growable: false);
      for (var i = 0; i < _steps; i++) {
        final step = fixedStep.stepSeconds;
        for (final follower in List<StepFollower>.of(_followers)) {
          follower.rememberPlace();
        }
        for (final start in List<void Function()>.of(_stepStarts)) {
          start();
        }
        fixedUpdate(step);
        for (final component in stepping) {
          if (component.isMounted && !component.isRemoving) {
            component.fixedUpdate(step);
          }
        }
        for (final end in List<void Function()>.of(_stepEnds)) {
          end();
        }
      }
    }
    super.update(dt);
  }
}
