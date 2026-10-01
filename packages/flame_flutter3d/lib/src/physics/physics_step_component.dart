/// [PhysicsStepComponent] steps one shared flutter3d_physics world, once a
/// frame, wherever Flame's own game loop already is.
library;

import 'package:flame/components.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart'
    show ActorSystemComponent, CollisionBridge;
import 'package:flame_flutter3d/src/host/bridge_priority.dart';
import 'package:flame_flutter3d/src/host/has_fixed_step.dart';
import 'package:flame_flutter3d/src/host/step_clock.dart';
import 'package:flame_flutter3d/src/physics/rigid_body_component.dart';
import 'package:flutter3d_physics/flutter3d_physics.dart';
import 'package:flutter3d_sim/flutter3d_sim.dart' show FixedStep;

/// The one place a bridged game's frame steps its [Dynamics] and dispatches
/// its [CollisionWorld]'s contacts.
///
/// **The physics half of what [ActorSystemComponent] is for actors.** A
/// [RigidBodyComponent] never steps anything, for the reason that class
/// gives: a hundred bridged crates each stepping the shared world would
/// step it a hundred times a frame. Something has to step it once, and every
/// game that used the bridge wrote this component for itself: the arcade,
/// the package's own example, a showcase page. It lives here now.
///
/// **Step, then whatever follows a body, then dispatch.** [update] calls
/// [Dynamics.step], then [afterStep], then [CollisionWorld.update], in that
/// order, because the last of them is what sends overlaps to every listener,
/// a [CollisionBridge] among them. Dispatching before the step would report
/// last frame's overlaps against this frame's picture. [afterStep] is the
/// seam for anything that follows a body the solver just moved and has to
/// be in place before the dispatch: a trigger sensor that rides on a solid
/// body, for instance, since two solids never overlap and only the sensor
/// can report them touching.
///
/// **In fixed steps, not in frames.** Flame's `dt` is whatever the frame
/// took: a sixtieth, a hundred-and-twentieth, a quarter of a second when a
/// laptop stalls. Integrated as it comes, the same jump reaches a different
/// height on a faster screen and a hitch lets a fast body step through a
/// wall. [step] spends the frame's time in whole steps of one size, at most
/// its `maxStepsPerFrame` of them, and keeps the remainder for the next
/// frame; contacts are dispatched after each step, so none is missed
/// between two. [alpha] is how far the frame is past the last step, and a
/// [RigidBodyComponent] handed this component draws its body that far
/// between its last two places rather than jumping from one to the next.
///
/// **Order it before whatever reads the result.** Flame updates components
/// by ascending priority; give this one a priority below the components that
/// read positions or react to contacts, as [ActorSystemComponent] is given
/// one below the actors' readers.
///
/// **In a `HasFixedStep` game it steps with the game**, once in each of the
/// game's steps, and [step] is not used: see [HasFixedStep].
final class PhysicsStepComponent extends Component
    with FixedStepUpdate
    implements StepClock {
  PhysicsStepComponent({
    required this.dynamics,
    required this.world,
    this.afterStep,
    FixedStep? step,
    super.priority = BridgePriority.physics,
  }) : step = step ?? FixedStep();

  /// The bodies this steps.
  final Dynamics dynamics;

  /// The world whose contacts this dispatches after the step.
  final CollisionWorld world;

  /// Runs between the solver and the dispatch, once a step. Null for a
  /// game with nothing to move there.
  final void Function()? afterStep;

  /// How the frame's time is cut into steps: one sixtieth of a second each
  /// unless given otherwise.
  final FixedStep step;

  /// How far this frame is past the last step, from 0 up to 1: the game's,
  /// when the game steps it.
  @override
  double get alpha => _game?.alpha ?? step.alpha;

  HasFixedStep? _game;

  @override
  void onMount() {
    super.onMount();
    _game = switch (findGame()) {
      final HasFixedStep game => game,
      _ => null,
    };
  }

  final Set<StepFollower> _followers = <StepFollower>{};

  /// [body] is told where its body was before each step, so it can draw
  /// between that and where the step put it. [RigidBodyComponent] does
  /// this for itself when handed this component.
  @override
  void follow(StepFollower body) => _followers.add(body);

  /// Stops telling [body]; it is removed, or no longer interpolates.
  @override
  void unfollow(StepFollower body) => _followers.remove(body);

  /// Counts the frames this has been updated in: the steps of one frame all
  /// see the same number. What a `CollisionBridge` handed this tells one
  /// frame's `onCollision` from the next by.
  int get frame => _frame;
  int _frame = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _frame++;
    if (_game != null) {
      return;
    }
    final steps = step.advance(dt);
    for (var i = 0; i < steps; i++) {
      fixedUpdate(step.stepSeconds);
    }
  }

  /// One step of the world, of [seconds], and its contacts.
  @override
  void fixedUpdate(double seconds) {
    for (final body in _followers) {
      body.rememberPlace();
    }
    dynamics.step(seconds);
    afterStep?.call();
    world.update();
  }
}
