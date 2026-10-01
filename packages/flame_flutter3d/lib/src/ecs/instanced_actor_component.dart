/// Many actors of one shape, each an instance of one batch rather than a node
/// of its own.
library;

import 'package:flame/components.dart' show Component;
import 'package:flame_flutter3d/flame_flutter3d.dart' show ActorComponent;
import 'package:flame_flutter3d/src/ecs/actor_component.dart'
    show ActorComponent;
import 'package:flame_flutter3d/src/host/step_clock.dart';
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:flutter3d_sim/flutter3d_sim.dart' show Actor, ActorSystem;
import 'package:vector_math/vector_math.dart' show Matrix4, Vector3;

/// One simulated [Actor] drawn as a slot of a shared [InstancedMeshNode].
///
/// **What [ActorComponent] is for a horde.** Each `ActorComponent` is a node
/// and a draw, which is right for a boss and wrong for two hundred monsters
/// of three kinds: that is two hundred draws where three would do.
/// `InstancedObject3dComponent` is one draw for many, but it flows from
/// Flame to the scene, and a horde's place is decided by the simulation. This
/// takes a slot in [batch] when it is mounted, writes the actor's body and
/// facing into it every frame — [stepper]'s `alpha` of the way from where the
/// body was before the step, as `ActorComponent` does — and gives the slot
/// back when it goes.
///
/// **It lives and dies with the actor**, both ways, as `ActorComponent` does:
/// an actor the simulation takes out takes this with it, and handed
/// [removesFrom], taking this out of the game takes the actor out of the
/// system.
///
/// **[batch] sits at the scene's origin, unturned**, as for
/// `InstancedObject3dComponent`: the transform written is the body's place in
/// the scene as it is.
class InstancedActorComponent extends Component implements StepFollower {
  InstancedActorComponent({
    required this.actor,
    required this.batch,
    this.stepper,
    this.removesFrom,
    this.lift = 0.0,
    super.priority,
  });

  final Actor actor;

  /// The batch this actor takes a slot in.
  final InstancedMeshNode batch;

  /// What steps [actor], for drawing it between its steps; null draws it
  /// where it is.
  final StepClock? stepper;

  /// The system [actor] leaves when this component leaves the game, or null
  /// for an actor this only draws.
  final ActorSystem? removesFrom;

  /// Metres added to the body's height before it is drawn: a mesh built with
  /// its feet at its origin under a body whose position is its middle.
  final double lift;

  InstanceHandle? _slot;

  /// The slot this actor is drawn through, while it is mounted.
  InstanceHandle? get slot => _slot;

  final Vector3 _before = Vector3.zero();
  final Vector3 _drawn = Vector3.zero();
  double _yawBefore = 0.0;
  bool _remembered = false;
  final Matrix4 _transform = Matrix4.identity();

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

  @override
  void onMount() {
    super.onMount();
    _remembered = false;
    _slot = batch.acquire();
    stepper?.follow(this);
    _write();
  }

  @override
  void onRemove() {
    stepper?.unfollow(this);
    final slot = _slot;
    _slot = null;
    if (slot != null && slot.live) {
      batch.release(slot);
    }
    final system = removesFrom;
    if (system != null && actor.exists) {
      system.remove(actor);
    }
    super.onRemove();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!actor.exists) {
      if (!isRemoving) {
        removeFromParent();
      }
      return;
    }
    _write();
  }

  void _write() {
    final slot = _slot;
    final body = actor.body;
    if (slot == null || body == null) {
      return;
    }
    final steps = stepper;
    final double yaw;
    if (steps != null && _remembered) {
      Vector3.mix(_before, body.position, steps.alpha, _drawn);
      yaw = _between(_yawBefore, actor.yaw, steps.alpha);
    } else {
      _drawn.setFrom(body.position);
      yaw = actor.yaw;
    }
    _transform
      ..setIdentity()
      ..setTranslationRaw(_drawn.x, _drawn.y + lift, _drawn.z)
      ..rotateY(yaw);
    slot.setTransform(_transform);
  }

  static double _between(double a, double b, double t) {
    const whole = 6.283185307179586;
    var turn = (b - a) % whole;
    if (turn > whole / 2.0) {
      turn -= whole;
    }
    return a + turn * t;
  }
}

/// A thing the simulation keeps that is not an actor — a shot in flight —
/// drawn as a slot of a shared [InstancedMeshNode] for as long as [place]
/// says it is still there.
///
/// [place] writes where it is this frame into the vector it is handed, and
/// answers false once it is gone, which takes this component and its slot
/// away. For a sim's own list of short-lived things the game mirrors one
/// component per item.
class InstancedPoseComponent extends Component {
  InstancedPoseComponent({
    required this.batch,
    required this.place,
    super.priority,
  });

  final InstancedMeshNode batch;

  /// Where the thing is now; false once it is gone.
  final bool Function(Vector3 at) place;

  InstanceHandle? _slot;
  final Vector3 _at = Vector3.zero();
  final Matrix4 _transform = Matrix4.identity();

  @override
  void onMount() {
    super.onMount();
    _slot = batch.acquire();
    _write();
  }

  @override
  void onRemove() {
    final slot = _slot;
    _slot = null;
    if (slot != null && slot.live) {
      batch.release(slot);
    }
    super.onRemove();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_write() && !isRemoving) {
      removeFromParent();
    }
  }

  bool _write() {
    final slot = _slot;
    if (slot == null) {
      return false;
    }
    if (!place(_at)) {
      return false;
    }
    _transform
      ..setIdentity()
      ..setTranslationRaw(_at.x, _at.y, _at.z);
    slot.setTransform(_transform);
    return true;
  }
}
