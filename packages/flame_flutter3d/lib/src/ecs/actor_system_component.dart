/// [ActorSystemComponent] steps one shared flutter3d_sim [ActorSystem],
/// once a frame, wherever Flame's own game loop already is.
library;

import 'package:flame/components.dart';
import 'package:flame_flutter3d/src/ecs/actor_component.dart';
import 'package:flame_flutter3d/src/host/bridge_priority.dart';
import 'package:flame_flutter3d/src/host/has_fixed_step.dart';
import 'package:flame_flutter3d/src/host/step_clock.dart';
import 'package:flutter3d_sim/flutter3d_sim.dart';

/// The one place a bridged game's frame steps a shared [ActorSystem].
///
/// **Plain [Component], not [PositionComponent].** It draws nothing and
/// sits nowhere — each actor it steps has its own [ActorComponent] for
/// that — so it carries none of the transform a [PositionComponent] would
/// otherwise make a caller invent an answer for.
///
/// **Why stepping lives here and not on every [ActorComponent].**
/// [ActorSystem.step]'s own doc states the protocol it is half of:
/// [ActorSystem.beginStep] must run once, immediately before it, every
/// frame — call `step` again without a fresh `beginStep` and it throws;
/// call `beginStep`/`step` more than once a frame and every actor's
/// physics runs twice that frame. A game with N actors sharing one
/// [ActorSystem] but stepping it from N different [ActorComponent]s would
/// do exactly that, and stepping the whole system N times to move a
/// world's worth of actors N times too fast is not something any one
/// actor's component can see from where it sits — only whoever owns the
/// system can. So [ActorComponent] itself never calls [ActorSystem.step]
/// or [ActorSystem.beginStep]; this is the only caller, and it calls the
/// pair exactly once per [update].
///
/// **In fixed steps, not in frames**, for the reason
/// `PhysicsStepComponent` gives: the frame's time is spent in whole steps of
/// [step]'s size, the `beginStep`/`step` pair once per step, and an
/// [ActorComponent] handed this component draws its actor [alpha] of the
/// way between its last two places.
///
/// **Why [focus] and [focusBody] are closures, not values captured once.**
/// [ActorSystem.step] needs to know where the world's one focus point is
/// *this frame* — a player's own position, typically — and a value taken
/// once at construction would freeze it at wherever that was when this
/// component was built. Reading a fresh `Vector3`/`Collider?` every
/// [update] costs one call each and is the only way this component can
/// hand [ActorSystem.step] a focus that has actually moved since.
///
/// **In a `HasFixedStep` game it steps with the game**, once in each of the
/// game's steps, and [step] is not used: see [HasFixedStep]. The system's
/// step is opened — [ActorSystem.beginStep] — at the *start* of the game's
/// step, before the game's own logic, and the actors are stepped later in it.
/// Opened just before the actors, it wiped whatever the game's logic had
/// already reported that step: a player's shot killed a monster and the death
/// was gone before anybody read it.
///
/// **One focus or several.** [focus] and [focusBody] name the one thing
/// everything chases; [foci] names several — the players of a co-op game —
/// and each actor then goes for the one it can reach first, as
/// [ActorSystem.step] explains. Exactly one of the two.
final class ActorSystemComponent extends Component
    with FixedStepUpdate
    implements StepClock {
  ActorSystemComponent({
    required this.system,
    this.focus,
    this.focusBody,
    this.foci,
    FixedStep? step,
    super.priority = BridgePriority.actors,
  }) : assert(
         (focus == null) != (foci == null),
         'an actor system is stepped towards one focus or several foci',
       ),
       step = step ?? FixedStep();

  /// The actor system every [ActorComponent] in this game shares.
  final ActorSystem system;

  /// Where the system's one focus point is, read fresh every step.
  final Vector3 Function()? focus;

  /// What the focus point belongs to, or null for a focus with no body of
  /// its own — read fresh every step, for the same reason as [focus].
  final Collider? Function()? focusBody;

  /// Every focus, read fresh every step: the living players, in an order that
  /// stays put, since [ActorSystem.damageToFoci] is read by it.
  final List<FocusPoint> Function()? foci;

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
    _game?.beforeEachStep(_open);
  }

  @override
  void onRemove() {
    _game?.removeBeforeEachStep(_open);
    _game = null;
    super.onRemove();
  }

  final Set<StepFollower> _followers = <StepFollower>{};

  /// [follower] is told where its body was before each step. [ActorComponent]
  /// does this for itself when handed this component.
  @override
  void follow(StepFollower follower) => _followers.add(follower);

  /// Stops telling [follower].
  @override
  void unfollow(StepFollower follower) => _followers.remove(follower);

  bool _opened = false;

  void _open() {
    system.beginStep();
    _opened = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_game != null) {
      return;
    }
    final steps = step.advance(dt);
    for (var i = 0; i < steps; i++) {
      _open();
      fixedUpdate(step.stepSeconds);
    }
  }

  /// One step of the system, of [seconds].
  @override
  void fixedUpdate(double seconds) {
    for (final follower in _followers) {
      follower.rememberPlace();
    }
    // Mounted in the middle of a game's step: the step was opened without us.
    if (!_opened) {
      system.beginStep();
    }
    _opened = false;
    final several = foci;
    if (several != null) {
      final points = several();
      // Nobody left to chase: the step is the game's to end, not ours.
      if (points.isEmpty) {
        return;
      }
      system.step(seconds, foci: points);
    } else {
      system.step(seconds, focus: focus!(), focusBody: focusBody?.call());
    }
  }
}
