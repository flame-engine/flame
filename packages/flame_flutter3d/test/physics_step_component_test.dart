/// [PhysicsStepComponent] steps, then runs its seam, then dispatches.
library;

import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flutter3d/flutter3d.dart' show Scene, SceneNode;
import 'package:flutter3d_physics/flutter3d_physics.dart';
import 'package:flutter3d_sim/flutter3d_sim.dart' show FixedStep;
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

final class _Log with CollisionListener {
  _Log(this.log);

  final List<String> log;

  @override
  void onCollisionStart(Collider self, Collider other) => log.add('contact');
}

void main() {
  test('one update steps the bodies, then runs afterStep, then dispatches '
      'the contacts afterStep made', () {
    // A body flying along X and a trigger that rides five metres above it,
    // put there by `afterStep`. A marker waits where the body will be after
    // one step. The contact can only be reported if the step ran first, the
    // sensor was moved second and the world dispatched last. Mutation:
    // dispatch before the step, or before `afterStep`, and the log has no
    // contact.
    final world = CollisionWorld();
    final dynamics = Dynamics(world: world, gravity: Vector3.zero());
    final body = dynamics.add(
      RigidBody(
        world: world,
        shape: CollisionBox(Vector3.all(0.5)),
        position: Vector3.zero(),
      ),
    );
    body.velocity.setValues(60.0, 0.0, 0.0);
    final log = <String>[];
    final sensor = world.add(
      Collider(
        shape: CollisionBox(Vector3.all(0.3)),
        position: Vector3(0.0, 5.0, 0.0),
        kind: ColliderKind.trigger,
        listener: _Log(log),
      ),
    );
    world.add(
      Collider(
        shape: CollisionBox(Vector3.all(0.1)),
        position: Vector3(1.0, 5.0, 0.0),
      ),
    );

    PhysicsStepComponent(
      dynamics: dynamics,
      world: world,
      afterStep: () {
        log.add('after');
        sensor.position.setFrom(body.position + Vector3(0.0, 5.0, 0.0));
      },
    ).update(1 / 60);

    expect(body.position.x, greaterThan(0.7), reason: 'the body never moved');
    expect(log, <String>['after', 'contact']);
  });

  test('with no afterStep it still steps and dispatches', () {
    final world = CollisionWorld();
    final dynamics = Dynamics(world: world, gravity: Vector3(0.0, -9.8, 0.0));
    final body = dynamics.add(
      RigidBody(
        world: world,
        shape: CollisionBox(Vector3.all(0.5)),
        position: Vector3(0.0, 5.0, 0.0),
      ),
    );

    PhysicsStepComponent(dynamics: dynamics, world: world).update(1 / 60);

    expect(body.position.y, lessThan(5.0));
  });

  ({Dynamics dynamics, RigidBody body, CollisionWorld world}) falling() {
    final world = CollisionWorld();
    final dynamics = Dynamics(world: world, gravity: Vector3(0.0, -9.8, 0.0));
    final body = dynamics.add(
      RigidBody(
        world: world,
        shape: CollisionBox(Vector3.all(0.5)),
        position: Vector3(0.0, 50.0, 0.0),
      ),
    );
    return (dynamics: dynamics, body: body, world: world);
  }

  test('the same second of play lands in the same place at any frame rate', () {
    // Integrated as the frames come, a body falls a different distance at
    // 30 and at 144 frames a second. In steps of one size it cannot.
    //
    // Mutation: step the solver by the frame's own dt.
    double after(double frame) {
      final it = falling();
      final stepper = PhysicsStepComponent(
        dynamics: it.dynamics,
        world: it.world,
      );
      for (var t = 0; t < (1.0 / frame).round(); t++) {
        stepper.update(frame);
      }
      return it.body.position.y;
    }

    final slow = after(1 / 30);
    expect(after(1 / 60), closeTo(slow, 1e-9));
    expect(after(1 / 120), closeTo(slow, 1e-9));
  });

  test('a stalled frame runs a few steps, not the whole stall', () {
    // A laptop lid shut for a second must not ask for sixty steps at once:
    // catching up takes longer than the stall and never finishes.
    final it = falling();
    var steps = 0;
    PhysicsStepComponent(
      dynamics: it.dynamics,
      world: it.world,
      afterStep: () => steps++,
      step: FixedStep(maxStepsPerFrame: 4),
    ).update(1.0);
    expect(steps, 4);
  });

  test('a body handed the stepper is drawn between its last two steps', () {
    // Half a step into the frame, the node is half way between where the
    // body was and where the last step put it.
    final it = falling();
    final stepper = PhysicsStepComponent(
      dynamics: it.dynamics,
      world: it.world,
    );
    final crate = RigidBodyComponent(
      body: it.body,
      stepper: stepper,
      node: SceneNode(),
      scene: Scene(),
      plane: BridgePlane.backdrop(flipY: false),
    )..onMount();

    stepper.update(1 / 60);
    final before = it.body.position.y;
    stepper.update(1.5 / 60);
    final after = it.body.position.y;
    crate.update(0.0);

    expect(stepper.alpha, closeTo(0.5, 1e-9));
    expect(crate.node.readPosition().y, closeTo((before + after) / 2.0, 1e-5));
  });

  test('a body at rest does not mark the scene changed', () {
    // The same fault a still bridged prop had: the body's place was written
    // onto the node every frame, and a written node redraws every shadow.
    //
    // Mutation: write the body's place whether or not it moved.
    final world = CollisionWorld();
    final dynamics = Dynamics(world: world, gravity: Vector3.zero());
    final body = dynamics.add(
      RigidBody(
        world: world,
        shape: CollisionBox(Vector3.all(0.5)),
        position: Vector3(1.0, 2.0, 3.0),
      ),
    );
    final stepper = PhysicsStepComponent(dynamics: dynamics, world: world);
    final crate = RigidBodyComponent(
      body: body,
      node: SceneNode(),
      scene: Scene(),
      plane: BridgePlane.ground(),
    )..onMount();
    stepper.update(1 / 60);
    crate.update(1 / 60);

    final epoch = SceneNode.changeEpoch;
    for (var i = 0; i < 5; i++) {
      stepper.update(1 / 60);
      crate.update(1 / 60);
    }
    expect(SceneNode.changeEpoch, epoch);
    expect(crate.node.readPosition(), Vector3(1.0, 2.0, 3.0));
  });
}
