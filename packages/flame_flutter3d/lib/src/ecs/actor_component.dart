/// [ActorComponent] bridges one flutter3d_sim [Actor] to Flame — the
/// actor's simulated body kept in step with the [SceneNode] a game draws it
/// as.
library;

import 'package:flame/collisions.dart' show CollisionCallbacks;
import 'package:flame/components.dart';
import 'package:flame_flutter3d/src/ecs/actor_system_component.dart';
import 'package:flame_flutter3d/src/host/step_clock.dart';
import 'package:flame_flutter3d/src/transform/object3d_component.dart';
import 'package:flame_flutter3d/src/transform/plane.dart';
import 'package:flutter3d/flutter3d.dart' show SceneNode;
import 'package:flutter3d_sim/flutter3d_sim.dart';

/// A Flame [PositionComponent] wrapping one flutter3d_sim [Actor] — the
/// same [SceneNode]/[BridgePlane] bridge [Object3dComponent] gives every
/// other bridged transform, plus the one extra hop an actor needs: its
/// body's simulated position lives on a [CharacterController], not on
/// [node].
///
/// **Why [direction] defaults to [SyncDirection.sceneToFlame].** An actor's
/// body is stepped by [ActorSystem.step] — run once a frame by
/// [ActorSystemComponent], never by this component — and that step is
/// scene-authoritative in exactly the sense [SyncDirection]'s own doc
/// already names it: nothing about a Flame position feeds back into it.
/// The rare game that drives an actor's body from a Flame-side animation
/// instead can still pass [SyncDirection.flameToScene] explicitly; this
/// default is only a default.
///
/// **Why [update] copies [Actor.body]'s position onto [node] before calling
/// `super.update`.** [Object3dComponent.update] reads `node.readPosition()`
/// — it has never heard of an [Actor], and should not have to, or every
/// bridge component in this package would need to know about every other
/// one's data model. The position [ActorSystem.step] just computed lives on
/// the [CharacterController] itself, so getting it onto the Flame side
/// means getting it onto [node] first. It is the same "sync the visual
/// thing from the real body" step `apps/flutter3d_showcase`'s rigid-body
/// demo already does by hand for a crate (`mesh.setPositionFrom(_crate
/// .position)`), done here once so every actor in a bridged game gets it
/// for free instead of every game re-deriving it.
///
/// **The component and the actor live and die together, both ways.** An
/// actor the simulation takes out — `ActorSystem.remove`, a horde burying its
/// dead — takes this component with it on the next [update]: it used to stay,
/// its node frozen where the body last stood, a monster drawn after it was
/// gone. The other way is [removesFrom]: handed the system, taking this
/// component out of the game takes the actor out of the system, where it used
/// to go on thinking, biting and blocking a corridor unseen. Left null, the
/// actor is whoever built it's to remove, which is right when the simulation
/// owns its actors and the component only draws one.
final class ActorComponent extends Object3dComponent
    with CollisionCallbacks
    implements StepFollower {
  ActorComponent({
    required this.actor,
    required super.node,
    required super.scene,
    required super.plane,
    this.stepper,
    this.removesFrom,
    super.direction = SyncDirection.sceneToFlame,
    super.elevation,
    super.position,
    super.size,
    super.anchor,
    super.angle,
    super.scale,
    super.children,
    super.priority,
    super.key,
  });

  /// The flutter3d_sim actor this component bridges to Flame.
  final Actor actor;

  /// What steps [actor], when this should draw between its steps; see
  /// `RigidBodyComponent.stepper`. Null draws it where it is.
  ///
  /// An [ActorSystemComponent], or the game itself when the game steps its
  /// own simulation in `HasFixedStep.fixedUpdate` — any [StepClock].
  final StepClock? stepper;

  /// The system [actor] leaves when this component leaves the game, or null
  /// for an actor this component only draws.
  final ActorSystem? removesFrom;

  final Vector3 _before = Vector3.zero();
  final Vector3 _drawn = Vector3.zero();
  double _yawBefore = 0.0;
  bool _remembered = false;

  /// Keeps where the actor's body is now, and which way it faces, as where
  /// it was before the next step. Called by [stepper] before each step.
  @override
  void rememberPlace() {
    final body = actor.body;
    if (body == null) {
      return;
    }
    _before.setFrom(body.position);
    _yawBefore = actor.yaw;
    _remembered = true;
  }

  /// Carries the actor's body across too, still moving; see
  /// `RigidBodyComponent.shiftScene`.
  @override
  void shiftScene(Vector3 by) {
    super.shiftScene(by);
    final body = actor.body;
    if (body == null) {
      return;
    }
    body.position.add(by);
    body.collider
      ..position.setFrom(body.position)
      ..refreshBounds();
    _before.add(by);
  }

  @override
  void onMount() {
    super.onMount();
    // Added again, it draws from where the body is, not from where it was
    // when it went.
    _remembered = false;
    stepper?.follow(this);
  }

  @override
  void onRemove() {
    stepper?.unfollow(this);
    final system = removesFrom;
    if (system != null && actor.exists) {
      system.remove(actor);
    }
    super.onRemove();
  }

  /// Copies the actor's body and facing onto [node], then lets
  /// [Object3dComponent.update] read them onto the Flame side.
  ///
  /// **Only when the scene is authoritative.** Flowing Flame to the scene,
  /// the node is written from Flame's position straight after, and copying
  /// the body there first did nothing but cost a write.
  ///
  /// **The facing too, not only the place.** An actor turns by its yaw,
  /// radians about Y with nought looking along −Z, which is the rotation a
  /// node is drawn with; without it every bridged actor slid about facing
  /// the one way it was built facing.
  @override
  void update(double dt) {
    if (!actor.exists) {
      // Gone from the simulation: gone from the game.
      if (!isRemoving) {
        removeFromParent();
      }
      return;
    }
    if (direction == SyncDirection.sceneToFlame) {
      final body = actor.body;
      // Null for an actor with no body (a turret, a director) and for one
      // that has been despawned — both are "nothing to copy", not an error.
      final steps = stepper;
      if (body != null && steps != null && _remembered) {
        Vector3.mix(_before, body.position, steps.alpha, _drawn);
        placeNode(_drawn);
      } else if (body != null) {
        placeNode(body.position);
      }
      // Turned between its steps as it is moved between them: a bot's place
      // glided and its facing clicked round sixty times a second.
      if (actor.facing != null) {
        turnNodeTo(
          steps != null && _remembered
              ? _between(_yawBefore, actor.yaw, steps.alpha)
              : actor.yaw,
        );
      }
    }
    super.update(dt);
  }

  /// [t] of the way from angle [a] to angle [b], the short way round.
  static double _between(double a, double b, double t) {
    const whole = 6.283185307179586;
    var turn = (b - a) % whole;
    if (turn > whole / 2.0) {
      turn -= whole;
    }
    return a + turn * t;
  }
}
