/// A [RigidBodyComponent] keeps a real [RigidBody]'s position mirrored onto
/// both a flutter3d [SceneNode] and its own Flame `position`, every frame.
library;

import 'package:flame/components.dart' show Component, PositionComponent;
import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:flutter3d_physics/flutter3d_physics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defaults to sceneToFlame — the body is authoritative', () {
    final world = CollisionWorld();
    final body = RigidBody(
      world: world,
      shape: CollisionBox(Vector3(0.5, 0.5, 0.5)),
      position: Vector3.zero(),
    );
    final component = RigidBodyComponent(
      body: body,
      node: SceneNode(),
      scene: Scene(),
      plane: BridgePlane.ground(),
    );

    expect(component.direction, SyncDirection.sceneToFlame);
  });

  test(
    'mounting adds the node to the scene, the same as any Object3dComponent',
    () {
      final world = CollisionWorld();
      final body = RigidBody(
        world: world,
        shape: CollisionBox(Vector3(0.5, 0.5, 0.5)),
        position: Vector3.zero(),
      );
      final scene = Scene();
      final node = SceneNode();
      final component = RigidBodyComponent(
        body: body,
        node: node,
        scene: scene,
        plane: BridgePlane.ground(),
      );

      component.onMount();

      expect(node.parent, scene.root);
    },
  );

  test('update copies the body position, after applyImpulse and a Dynamics '
      'step, onto both the node and the Flame position', () {
    final world = CollisionWorld();
    final dynamics = Dynamics(world: world, gravity: Vector3.zero());
    final body = dynamics.add(
      RigidBody(
        world: world,
        shape: CollisionBox(Vector3(0.5, 0.5, 0.5)),
        position: Vector3(0.0, 5.0, 0.0),
      ),
    );
    final scene = Scene();
    final node = SceneNode();
    final plane = BridgePlane.ground();
    final component = RigidBodyComponent(
      body: body,
      node: node,
      scene: scene,
      plane: plane,
    )..onMount();

    body.applyImpulse(Vector3(6.0, 0.0, 0.0));
    dynamics.step(1 / 60);
    // The body actually moved — otherwise this test would pass even if
    // `update` copied nothing.
    expect(body.position.x, isNot(0.0));

    component.update(1 / 60);

    expect(node.readPosition(), body.position);
    expect(component.position, plane.to2d(body.position));
  });

  test('a second update tracks a body that keeps moving', () {
    final world = CollisionWorld();
    final dynamics = Dynamics(world: world, gravity: Vector3.zero());
    final body = dynamics.add(
      RigidBody(
        world: world,
        shape: CollisionBox(Vector3(0.5, 0.5, 0.5)),
        position: Vector3.zero(),
      ),
    );
    final scene = Scene();
    final node = SceneNode();
    final plane = BridgePlane.ground();
    final component = RigidBodyComponent(
      body: body,
      node: node,
      scene: scene,
      plane: plane,
    )..onMount();

    body.applyImpulse(Vector3(4.0, 0.0, 2.0));
    dynamics.step(1 / 60);
    component.update(1 / 60);
    final firstX = node.readPosition().x;

    dynamics.step(1 / 60);
    component.update(1 / 60);

    expect(node.readPosition(), body.position);
    expect(node.readPosition().x, isNot(firstX));
    expect(component.position, plane.to2d(body.position));
  });

  testWithGame<FlameGame>(
    'teleported, a body is drawn where it went, still and awake',
    FlameGame.new,
    (game) async {
      // Written into the collider, a respawn slid across the level.
      //
      // Mutation: move the collider and nothing else.
      final world = CollisionWorld();
      final dynamics = Dynamics(world: world, gravity: Vector3.zero());
      final body = dynamics.add(
        RigidBody(
          world: world,
          shape: CollisionBox(Vector3.all(0.5)),
          position: Vector3.zero(),
        ),
      );
      final stepper = PhysicsStepComponent(dynamics: dynamics, world: world);
      final crate = RigidBodyComponent(
        body: body,
        node: SceneNode(),
        scene: Scene(),
        plane: BridgePlane.ground(),
        stepper: stepper,
      );
      game.addAll(<Component>[stepper, crate]);
      await game.ready();
      body
        ..applyImpulse(Vector3(3.0, 0.0, 0.0))
        ..sleep();
      game.update(1 / 60 + 1 / 120);

      crate.teleport(Vector3(40.0, 0.0, 0.0));
      game.update(1 / 240);
      expect(crate.node.readPosition().x, closeTo(40.0, 1e-6));
      expect(body.velocity.length, 0.0);
      expect(body.isAsleep, isFalse);
    },
  );

  testWithGame<FlameGame>(
    'handed its dynamics, a removed crate takes its body out of the world',
    FlameGame.new,
    (game) async {
      // Mutation: leave the body behind.
      final world = CollisionWorld();
      final dynamics = Dynamics(world: world, gravity: Vector3.zero());
      final body = dynamics.add(
        RigidBody(
          world: world,
          shape: CollisionBox(Vector3.all(0.5)),
          position: Vector3.zero(),
        ),
      );
      final crate = RigidBodyComponent(
        body: body,
        node: SceneNode(),
        scene: Scene(),
        plane: BridgePlane.ground(),
        removeFrom: dynamics,
      );
      final shelf = PositionComponent();
      game.addAll(<Component>[crate, shelf]);
      await game.ready();

      crate.parent = shelf;
      await game.ready();
      await Future<void>.delayed(Duration.zero);
      expect(dynamics.bodies, contains(body), reason: 'moved, not gone');

      crate.removeFromParent();
      await game.ready();
      await Future<void>.delayed(Duration.zero);
      expect(dynamics.bodies, isNot(contains(body)));
      expect(dynamics.bodyOf(body.collider), isNull);
    },
  );
}
