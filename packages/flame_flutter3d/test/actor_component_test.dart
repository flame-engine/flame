/// [ActorComponent] keeps a Flame position in step with the body a real
/// flutter3d_sim [Actor] simulates.
library;

import 'package:flame_flutter3d/src/ecs/actor_component.dart';
import 'package:flame_flutter3d/src/ecs/actor_system_component.dart';
import 'package:flame_flutter3d/src/transform/plane.dart';
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:flutter3d_sim/flutter3d_sim.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart' hide Plane;

ActorSystem _system() =>
    ActorSystem(world: CollisionWorld(), random: GameRandom(1));

void main() {
  test('copies the actor body position onto the Flame position each frame', () {
    final scene = Scene();
    final node = SceneNode();
    final system = _system();
    final body = CharacterController(world: system.world);
    final actor = system.spawn(body: body);

    final component = ActorComponent(
      actor: actor,
      node: node,
      scene: scene,
      plane: BridgePlane.ground(),
    )..onMount();

    body.position.setValues(3.0, 0.0, 4.0);
    component.update(1 / 60);

    expect(component.position, Vector2(3.0, 4.0));
    // The node was updated too, not only the Flame side — the body's
    // position reaches it through `node`, not around it.
    expect(node.readPosition(), Vector3(3.0, 0.0, 4.0));
  });

  test('leaves the Flame position untouched when the actor has no body', () {
    final scene = Scene();
    final node = SceneNode()..setPosition(1.0, 0.0, 2.0);
    final system = _system();
    final actor = system.spawn();

    final component = ActorComponent(
      actor: actor,
      node: node,
      scene: scene,
      plane: BridgePlane.ground(),
    )..onMount();

    component.update(1 / 60);

    expect(component.position, Vector2(1.0, 2.0));
  });

  test('onRemove detaches the node without throwing after despawn', () {
    final scene = Scene();
    final node = SceneNode();
    final system = _system();
    final body = CharacterController(world: system.world);
    final actor = system.spawn(body: body);

    final component = ActorComponent(
      actor: actor,
      node: node,
      scene: scene,
      plane: BridgePlane.ground(),
    )..onMount();

    system.remove(actor);
    expect(actor.exists, isFalse);

    expect(component.onRemove, returnsNormally);
    expect(node.parent, isNull);
  });

  test('update does not throw once its actor has been despawned', () {
    final scene = Scene();
    final node = SceneNode();
    final system = _system();
    final body = CharacterController(world: system.world);
    final actor = system.spawn(body: body);

    final component = ActorComponent(
      actor: actor,
      node: node,
      scene: scene,
      plane: BridgePlane.ground(),
    )..onMount();

    system.remove(actor);

    // actor.body now reads null; update must treat that as "nothing to
    // copy", the same as an actor that never had a body.
    expect(() => component.update(1 / 60), returnsNormally);
  });

  test('turns the node the way the actor faces', () {
    // An actor's yaw is radians about Y, nought looking down -Z; a quarter
    // turn left looks down -X. Without it every bridged actor slid about
    // facing the way it was built.
    //
    // Mutation: copy only the body's position.
    final system = _system();
    final actor = system.spawn(
      body: CharacterController(world: system.world),
      facing: Facing(yaw: 1.5707963267948966),
    );
    final component = ActorComponent(
      actor: actor,
      node: SceneNode(),
      scene: Scene(),
      plane: BridgePlane.ground(),
    )..onMount();
    component.update(1 / 60);

    final forward = component.node.readRotation().asRotationMatrix().transform(
      Vector3(0.0, 0.0, -1.0),
    );
    expect(forward.x, closeTo(-1.0, 1e-6));
    expect(forward.z, closeTo(0.0, 1e-6));
  });

  test('turns between its steps as it moves between them', () {
    // Its place glided between two steps and its facing clicked round.
    //
    // Mutation: turn the node to the yaw the last step left.
    final system = _system();
    final actor = system.spawn(
      body: CharacterController(world: system.world),
      facing: Facing(),
    );
    final stepper = ActorSystemComponent(system: system, focus: Vector3.zero);
    final component = ActorComponent(
      actor: actor,
      node: SceneNode(),
      scene: Scene(),
      plane: BridgePlane.ground(),
      stepper: stepper,
    )..onMount();

    component.rememberPlace();
    actor.facing!.yaw = 1.5707963267948966;
    stepper.step.advance(1 / 60 + 1 / 120);
    expect(stepper.alpha, closeTo(0.5, 1e-9));
    component.update(0.0);

    final forward = component.node.readRotation().asRotationMatrix().transform(
      Vector3(0.0, 0.0, -1.0),
    );
    // Half of a quarter turn left: an eighth, between -Z and -X.
    expect(forward.x, closeTo(-0.7071, 1e-3));
    expect(forward.z, closeTo(-0.7071, 1e-3));
  });
}
