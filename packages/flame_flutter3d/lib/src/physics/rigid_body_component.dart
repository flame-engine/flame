/// A physics-authoritative [RigidBody] kept at the same place as a flutter3d
/// [SceneNode] and a Flame [PositionComponent].
library;

import 'dart:async' show scheduleMicrotask;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart' show CollisionBridge;
import 'package:flame_flutter3d/src/host/step_clock.dart';
import 'package:flame_flutter3d/src/physics/collision_bridge.dart'
    show CollisionBridge;
import 'package:flame_flutter3d/src/physics/physics_step_component.dart';
import 'package:flame_flutter3d/src/transform/object3d_component.dart';
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:flutter3d_physics/flutter3d_physics.dart';

/// Bridges one [RigidBody] onto a flutter3d [SceneNode] and, through
/// [Object3dComponent], onto a Flame [PositionComponent] — and, through the
/// [CollisionCallbacks] this mixes in, onto the method surface
/// [CollisionBridge] relays flutter3d's own collision events into.
///
/// **[body] is built and stepped elsewhere.** Constructing a [RigidBody]
/// already adds it to the [CollisionWorld] it names, and almost every caller
/// also hands it to a [Dynamics] the way `Dynamics.add` wants — so by the
/// time a [RigidBodyComponent] wraps one, both have very likely already
/// happened. This component never calls `Dynamics.step` itself: exactly one
/// thing should step a shared simulation once a frame, the way a single
/// `ActorSystemComponent` would centralize `ActorSystem.step` rather than
/// letting every actor-bridging component step its own copy — a hundred
/// `RigidBodyComponent`s each stepping the same `Dynamics` is a hundred steps
/// a frame, and the bug that produces is "everything moves too fast," which
/// is a strange place to have to go looking for "a component and a game loop
/// both call step."
///
/// **Defaults to [SyncDirection.sceneToFlame].** [SyncDirection]'s own doc
/// comment already says a rigid body is scene-authoritative: the solver
/// decides where it is, and Flame's `position` is a read of that decision,
/// never a write into it. A caller that truly wants a Flame-driven body — an
/// input-controlled crate, say — should not reach for this component at all;
/// nothing here supports writing a Flame position back onto a [RigidBody]'s
/// [Collider], because [Collider.moveTo] is [Dynamics]'s to call, not a
/// transform bridge's.
class RigidBodyComponent extends Object3dComponent
    with CollisionCallbacks
    implements StepFollower {
  RigidBodyComponent({
    required this.body,
    required super.node,
    required super.scene,
    required super.plane,
    this.stepper,
    this.removeFrom,
    super.direction,
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

  /// The physics body this component tracks.
  ///
  /// Owned by whoever built it — this component never constructs the body,
  /// and removes it from its [CollisionWorld] only when handed [removeFrom];
  /// otherwise it reads [RigidBody.position] every frame and nothing else.
  final RigidBody body;

  /// What steps [body], when this should draw between its steps: the frame
  /// usually falls between two, and a body drawn where the last step left
  /// it moves in sixtieth-of-a-second jumps on a screen that shows more.
  /// Null draws it where it is.
  final PhysicsStepComponent? stepper;

  /// The dynamics [body] leaves, and its collision world with it, when this
  /// component leaves the game; null leaves it to whoever built it.
  ///
  /// **A despawned crate was still solid.** With the body left behind, a
  /// crate removed from Flame stayed in the world, unseen, for everything
  /// to bump into. Taken out when the component is gone, not when Flame
  /// moves it to a new parent, and never from inside a contact: Flame
  /// removes components at the start of a frame, between steps.
  final Dynamics? removeFrom;

  final Vector3 _before = Vector3.zero();
  final Vector3 _drawn = Vector3.zero();
  bool _remembered = false;

  /// Keeps where [body] is now as where it was before the next step. Called
  /// by [stepper] before each step.
  @override
  void rememberPlace() {
    _before.setFrom(body.position);
    _remembered = true;
  }

  /// Puts [body] at [to], still and awake, and draws it there at once.
  ///
  /// **Moved, not slid.** Written straight into the collider, a respawned
  /// body was drawn sliding across the level from where it had been, since
  /// the drawing runs between the last two steps, and a body asleep where
  /// it was stayed asleep in the air where it went.
  void teleport(Vector3 to) {
    body.collider
      ..moveTo(to)
      ..clearDelta();
    body
      ..velocity.setZero()
      ..wake();
    _before.setFrom(to);
    placeNode(to);
  }

  /// Carries the body across too, still moving, and where it was before the
  /// step with it, so it is not drawn sliding back across the world.
  @override
  void shiftScene(Vector3 by) {
    super.shiftScene(by);
    body.collider
      ..moveTo(body.position + by)
      ..clearDelta();
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
    final dynamics = removeFrom;
    if (dynamics != null) {
      scheduleMicrotask(() {
        if (!isMounted && parent == null && dynamics.bodies.contains(body)) {
          dynamics.remove(body);
        }
      });
    }
    super.onRemove();
  }

  /// Copies [body]'s current position onto [node], then defers to
  /// [Object3dComponent.update] to carry that onto the Flame side.
  ///
  /// The same line every current caller of `flutter3d_physics` already
  /// writes by hand — `mesh.setPositionFrom(body.position)` in
  /// `apps/flutter3d_showcase/lib/pages/physics_particles/rigid_bodies.dart`
  /// — generalized once here so a Flame-bridged body does not need a
  /// bespoke per-frame update to stay honest about where its physics really
  /// put it.
  @override
  void update(double dt) {
    final steps = stepper;
    if (steps != null && _remembered) {
      Vector3.mix(_before, body.position, steps.alpha, _drawn);
      placeNode(_drawn);
    } else {
      placeNode(body.position);
    }
    super.update(dt);
  }
}
