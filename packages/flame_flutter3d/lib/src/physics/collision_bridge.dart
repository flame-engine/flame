/// Re-fires flutter3d's own [CollisionListener] events as calls into
/// Flame's [CollisionCallbacks] surface, for one [Collider] at a time.
library;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart' show RigidBodyComponent;
import 'package:flame_flutter3d/src/physics/physics_step_component.dart';
import 'package:flame_flutter3d/src/physics/rigid_body_component.dart'
    show RigidBodyComponent;
import 'package:flame_flutter3d/src/transform/object3d_component.dart';
import 'package:flame_flutter3d/src/transform/plane.dart';
import 'package:flutter3d_physics/flutter3d_physics.dart';

/// A plain Dart object, not a [Component] — it draws nothing and has no
/// per-frame update of its own. All it does is sit as [collider]'s
/// [CollisionListener] and translate what [CollisionWorld] tells it into
/// calls on [component]'s [CollisionCallbacks] methods.
///
/// Constructing one attaches it: `collider.listener = this` happens in the
/// constructor, so a caller wires a bridge into the world simply by building
/// it, the same way `RigidBodyComponent` needs no separate "activate" step
/// once it exists.
///
/// ## The reference mismatch, and why nothing here papers over it
///
/// flutter3d's [CollisionListener] reports a pair of [Collider]s.
/// [CollisionCallbacks] wants a [PositionComponent]. `flutter3d_physics`
/// does not know Flame exists, so a [Collider] never carries a component
/// back to hand one over — a caller has to say how to find it, and
/// [resolveOther] is that answer: a lookup into whatever registry of
/// collider-to-component the caller already keeps (one entry per bridged
/// [RigidBodyComponent], typically). **When [resolveOther] returns null —
/// the other side of the contact is level geometry, a physics-only body
/// with no Flame component, or anything else nothing on the Flame side
/// represents — this bridge calls nothing.** There is no
/// [PositionComponent] to hand [CollisionCallbacks] in that case, and
/// inventing one, or routing the event to [component] with a null other,
/// would tell Flame code something untrue: that it collided with something
/// that, from Flame's point of view, does not exist. This is the collision
/// contact shape mismatch flagged as a real design commitment rather than
/// an oversight — silence is the correct behaviour, not a gap to fill
/// later.
///
/// ## The contact shape mismatch
///
/// flutter3d's collision system reports overlap as a pair of colliders —
/// there is no manifold, and [Contact] (built by `contactBetween`, which
/// this class does not call) carries only a normal and a depth even when
/// something does compute one. Flame's own signature has no room for either:
/// [CollisionCallbacks.onCollisionStart] and `.onCollision` take a
/// `List<Vector2>` of intersection points and nothing else. This bridge does
/// not try to synthesize a normal or a depth into that set — it has nowhere
/// to put them, and inventing a fake one would be worse than sending none.
/// What it sends instead is the cheapest honest stand-in for "roughly where
/// this touched": the midpoint of the two colliders' centres, projected
/// through [component]'s own [BridgePlane] via `plane.to2d`. For two boxes
/// of the same size that midpoint is the middle of their overlap; for boxes
/// of different sizes it can fall outside it (a 0.6 sensor meeting a 0.4
/// box 0.9 apart overlaps over [0.5, 0.6], and the midpoint is 0.45). That
/// is close enough to "where they touch" for a callback whose real job is
/// handing over a component
/// reference, not reporting physics. A caller that needs the actual normal
/// or depth reads [Collider.listener]'s own flutter3d-side callback
/// directly — this bridge relays the event onward, it does not replace the
/// flutter3d-side one.
final class CollisionBridge with CollisionListener {
  CollisionBridge({
    required this.collider,
    required this.component,
    required this.resolveOther,
    this.stepper,
    BridgePlane? plane,
  }) : plane =
           plane ??
           (component is Object3dComponent
               ? (component as Object3dComponent).plane
               : throw ArgumentError.value(
                   component,
                   'component',
                   'is not bridged, so a plane has to be given',
                 )) {
    collider.listener = this;
  }

  /// The flutter3d collider whose events this bridge relays. Bridged the
  /// moment this object is constructed.
  final Collider collider;

  /// The Flame-side component [collider] belongs to — the target every
  /// relayed callback lands on. A `RigidBodyComponent`, an `ActorComponent`,
  /// or any component with Flame's collision callbacks.
  ///
  /// **Any of them, not only a rigid body's.** An actor's body has a
  /// collider as a crate's does, and a bot touching the ship could not be
  /// told so through this bridge.
  final CollisionCallbacks component;

  /// Where a contact's midpoint is put on Flame's side: [component]'s own
  /// plane when it is bridged.
  final BridgePlane plane;

  /// Finds the [PositionComponent] bridged to the *other* collider in a
  /// contact, or null when nothing on the Flame side represents it.
  ///
  /// Typically a lookup into a `Map<Collider, PositionComponent>` the
  /// caller keeps — one entry per bridged component — since a bare
  /// [Collider] carries nothing back to whatever Flame component (if any)
  /// it belongs to.
  final PositionComponent? Function(Collider other) resolveOther;

  /// What steps the world, when [onCollision] should come once a frame, as
  /// Flame's own collision detection calls it, rather than once a step.
  ///
  /// **A frame of three steps touched three times.** The world reports an
  /// overlap after every step, and a damage-over-time written against
  /// Flame's once-a-frame `onCollision` took three times the damage on a
  /// slow frame and none on a frame with no step. Handed the stepper, this
  /// relays it once for each partner in each frame the two touch. The start
  /// and the end of a contact are events, and are told when they happen.
  final PhysicsStepComponent? stepper;

  final Map<PositionComponent, int> _toldInFrame = <PositionComponent, int>{};

  /// Stops relaying: clears [collider]'s listener, if it is still this
  /// bridge, and leaves it alone if something else has taken it since.
  ///
  /// For a collider that outlives its component, a body put back in a pool
  /// say. A bridge whose collider leaves the world with its component needs
  /// no call, and a removed [component] hears nothing either way (see
  /// [onCollisionStart]).
  void detach() {
    if (identical(collider.listener, this)) {
      collider.listener = null;
    }
  }

  /// Relays the start of a contact to [component], unless [resolveOther]
  /// finds nothing on the Flame side for [other] or [component] has been
  /// removed from its game: Flame's own collision system does not call a
  /// removed component either, and a despawned ship hearing it hit a bot
  /// is a callback into a game object that is gone.
  @override
  void onCollisionStart(Collider self, Collider other) {
    if (component.isRemoved) {
      return;
    }
    final target = resolveOther(other);
    if (target == null) {
      return;
    }
    if (_touching.add(target)) {
      _endWhenGone(target);
    }
    component.onCollisionStart(_pointFor(self, other), target);
  }

  @override
  void onCollision(Collider self, Collider other) {
    if (component.isRemoved) {
      return;
    }
    final target = resolveOther(other);
    if (target == null) {
      return;
    }
    final steps = stepper;
    if (steps != null) {
      if (_toldInFrame[target] == steps.frame) {
        return;
      }
      _toldInFrame[target] = steps.frame;
    }
    component.onCollision(_pointFor(self, other), target);
  }

  @override
  void onCollisionEnd(Collider self, Collider other) {
    if (component.isRemoved) {
      return;
    }
    final target = resolveOther(other);
    if (target == null || !_touching.remove(target)) {
      return;
    }
    _toldInFrame.remove(target);
    component.onCollisionEnd(target);
  }

  /// What [component] is touching, as far as it has been told.
  final Set<PositionComponent> _touching = <PositionComponent>{};

  /// **A partner removed mid-contact ends the contact.** Flame's own
  /// hitboxes end both sides of a contact when one of them goes; here the
  /// world said nothing, the other side was never told, and it went on
  /// counting the removed one among its `activeCollisions`. Checked a
  /// moment after the removal, since Flame moves a component to a new
  /// parent by removing and mounting it.
  void _endWhenGone(PositionComponent target) {
    target.removed.then((_) {
      if (target.isMounted || target.parent != null) {
        if (_touching.contains(target)) {
          _endWhenGone(target);
        }
        return;
      }
      if (_touching.remove(target) && !component.isRemoved) {
        component.onCollisionEnd(target);
      }
    });
  }

  /// The midpoint of [self] and [other]'s centres, on [component]'s plane,
  /// as the one-element point list Flame's callback signature wants. See
  /// this class's own doc comment for why a midpoint and not a real contact
  /// point.
  List<Vector2> _pointFor(Collider self, Collider other) => [
    plane.to2d((self.position + other.position) * 0.5),
  ];
}
