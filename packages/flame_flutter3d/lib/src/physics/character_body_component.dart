import 'dart:async' show scheduleMicrotask;

import 'package:flame/collisions.dart' show CollisionCallbacks;
import 'package:flame_flutter3d/src/host/has_fixed_step.dart';
import 'package:flame_flutter3d/src/host/step_clock.dart';
import 'package:flame_flutter3d/src/transform/object3d_component.dart';
import 'package:flutter3d_physics/flutter3d_physics.dart'
    show CharacterController, CollisionWorld;
import 'package:vector_math/vector_math.dart' show Vector3;

/// A `CharacterController` with no actor round it, carried across the
/// bridge: the body a platformer's runner moves, Pitfall Harry's.
///
/// **What the platformer already has, reached from Flame.** A runner in
/// `flutter3d_game_platformer` runs, jumps twice, grabs ladders and ropes,
/// and moves a character controller; what it lacked on Flame's side was a
/// component that steps it with the game and puts it where it is. [drive]
/// is that step, `runner.step(dt, input)` say, and runs in the game's fixed
/// steps when the game has `HasFixedStep`, once a frame otherwise. The body's
/// place is written onto the node and read back to Flame, drawn between its
/// last two steps when the steps are fixed.
///
/// **A body the game moves itself** — a genre whose own `step` moves its
/// heroes, called from the game's `fixedUpdate` — has no [drive] and is
/// handed the game as its [stepper]. It is then told to keep its place at
/// the start of each step, before the game moves it. Keeping it in its own
/// `fixedUpdate`, which runs after the game's, kept the place the game had
/// already moved it to, and the body was drawn with no smoothing at all.
class CharacterBodyComponent extends Object3dComponent
    with CollisionCallbacks, FixedStepUpdate
    implements StepFollower {
  CharacterBodyComponent({
    required this.body,
    required super.node,
    required super.scene,
    required super.plane,
    this.drive,
    this.stepper,
    this.removeFrom,
    super.size,
    super.anchor,
    super.priority,
  });

  /// The body being moved.
  final CharacterController body;

  /// What moves [body] by one step of the given seconds.
  final void Function(double dt)? drive;

  /// What steps [body] when [drive] does not, and tells this component to
  /// keep its place before each step: the game, for a body the game's own
  /// simulation moves. Null keeps the place in this component's own step.
  final StepClock? stepper;

  @override
  void onMount() {
    super.onMount();
    _stepped = false;
    stepper?.follow(this);
  }

  @override
  void rememberPlace() {
    _before.setFrom(body.position);
    _stepped = true;
  }

  /// The world [body]'s collider leaves when this component leaves the game;
  /// null leaves it to whoever built it. A despawned character otherwise
  /// stayed in the world, unseen and solid — `RigidBodyComponent.removeFrom`
  /// says the same of a crate, and is taken out the same way.
  final CollisionWorld? removeFrom;

  @override
  void onRemove() {
    stepper?.unfollow(this);
    final world = removeFrom;
    if (world != null) {
      final collider = body.collider;
      scheduleMicrotask(() {
        if (!isMounted && parent == null && identical(collider.world, world)) {
          world.remove(collider);
        }
      });
    }
    super.onRemove();
  }

  final Vector3 _before = Vector3.zero();
  final Vector3 _drawn = Vector3.zero();
  bool _stepped = false;

  /// Carries the body across too, still moving; see
  /// `RigidBodyComponent.shiftScene`.
  @override
  void shiftScene(Vector3 by) {
    super.shiftScene(by);
    body.position.add(by);
    body.collider
      ..position.setFrom(body.position)
      ..refreshBounds();
    _before.add(by);
  }

  @override
  void fixedUpdate(double step) {
    if (stepper == null) {
      rememberPlace();
    }
    drive?.call(step);
  }

  @override
  void update(double dt) {
    final game = findGame();
    if (game is! HasFixedStep) {
      drive?.call(dt);
    }
    final clock = stepper ?? (game is HasFixedStep ? game : null);
    if (clock != null && _stepped) {
      Vector3.mix(_before, body.position, clock.alpha, _drawn);
      placeNode(_drawn);
    } else {
      placeNode(body.position);
    }
    super.update(dt);
  }
}
