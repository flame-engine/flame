import 'dart:math' as math;

import 'package:flame_3d/collisions.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/physics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhysicsWorld3D & RigidBody3D Sequential Impulse solver', () {
    test('freefall under gravity and Newtonian restitution bounce', () {
      final physics = PhysicsWorld3D(
        gravity: Vector3(0, -9.81, 0),
      );
      final floor = RigidBody3D(
        bodyType: BodyType3D.static,
        shape: BoxShape3D(halfExtents: Vector3(10, 0.5, 10)),
        position: Vector3(0, -0.5, 0),
      );
      final ball = RigidBody3D(
        shape: SphereShape3D(radius: 0.5),
        position: Vector3(0, 4.5, 0), // Bottom starts 4.0m above y=0 floor.
        restitution: 0.8,
        linearDamping: 0.0,
        canSleep: false,
      );
      physics
        ..addBody(floor)
        ..addBody(ball);

      var touchedFloor = false;
      var reboundApexY = 0.0;
      for (var step = 0; step < 180; step++) {
        final prevVy = ball.linearVelocity.y;
        physics.step(1.0 / 60.0);
        if (prevVy < -1.0 && ball.linearVelocity.y > 1.0) {
          touchedFloor = true;
        }
        if (touchedFloor && ball.position.y > reboundApexY) {
          reboundApexY = ball.position.y;
        }
      }

      expect(touchedFloor, isTrue);
      // Dropped from center y=4.5 (`h=4.0` above `y=0.5` contact center):
      // theoretical rebound center `0.5 + 0.8^2 * 4.0 = 3.06m`.
      expect(reboundApexY, greaterThan(2.6));
      expect(reboundApexY, lessThan(3.5));
    });

    test('stacked boxes settle flat and enter sleep cleanly', () {
      final physics = PhysicsWorld3D(
        sleepTimeThreshold: 0.35,
        velocityIterations: 10,
        positionIterations: 4,
      );
      final floor = RigidBody3D(
        bodyType: BodyType3D.static,
        shape: BoxShape3D(halfExtents: Vector3(10, 0.5, 10)),
        position: Vector3(0, -0.5, 0),
        friction: 0.8,
      );
      final boxShape = BoxShape3D(halfExtents: Vector3.all(0.5));
      final b1 = RigidBody3D(
        shape: boxShape,
        position: Vector3(0, 0.52, 0),
        friction: 0.8,
      );
      final b2 = RigidBody3D(
        shape: boxShape,
        position: Vector3(0, 1.56, 0),
        friction: 0.8,
      );
      final b3 = RigidBody3D(
        shape: boxShape,
        position: Vector3(0, 2.6, 0),
        friction: 0.8,
      );
      physics
        ..addBody(floor)
        ..addBody(b1)
        ..addBody(b2)
        ..addBody(b3);

      for (var i = 0; i < 240; i++) {
        physics.step(1.0 / 60.0);
      }

      expect(b1.position.y, closeTo(0.5, 0.03));
      expect(b2.position.y, closeTo(1.5, 0.04));
      expect(b3.position.y, closeTo(2.5, 0.05));
      expect(b1.isSleeping, isTrue);
      expect(b2.isSleeping, isTrue);
      expect(b3.isSleeping, isTrue);
    });

    test(
      'off-center impulse induces coupled linear velocity and torque spin',
      () {
        final physics = PhysicsWorld3D(gravity: Vector3.zero());
        final body = RigidBody3D(
          shape: BoxShape3D(halfExtents: Vector3.all(0.5)),
          mass: 2.0,
          linearDamping: 0.0,
          angularDamping: 0.0,
          canSleep: false,
        );
        physics.addBody(body);

        // Push +X at top edge `(0, +0.5, 0)`: torque `(0, 0.5, 0) x (4, 0, 0)`.
        body.applyImpulse(
          Vector3(4.0, 0.0, 0.0),
          worldPoint: Vector3(0, 0.5, 0),
        );
        expect(body.linearVelocity.x, closeTo(2.0, 1e-5));
        expect(body.angularVelocity.z, lessThan(-1.0));

        for (var i = 0; i < 30; i++) {
          physics.step(1.0 / 60.0);
        }
        expect(body.position.x, closeTo(1.0, 1e-3));
        expect(body.rotation.w, lessThan(0.99));
      },
    );

    test('BallSocketJoint3D pendulum and HingeJoint3D angle limits', () {
      final physics = PhysicsWorld3D(
        velocityIterations: 12,
        positionIterations: 5,
      );
      final pivot = RigidBody3D(
        bodyType: BodyType3D.static,
        shape: SphereShape3D(radius: 0.1),
        position: Vector3(0, 5, 0),
      );
      final bob = RigidBody3D(
        shape: SphereShape3D(radius: 0.25),
        position: Vector3(2, 5, 0),
        canSleep: false,
      );
      final ballJoint = BallSocketJoint3D(
        bodyA: pivot,
        bodyB: bob,
        localAnchorA: Vector3.zero(),
        localAnchorB: Vector3(-2, 0, 0),
      );
      physics
        ..addBody(pivot)
        ..addBody(bob)
        ..addJoint(ballJoint);

      for (var i = 0; i < 90; i++) {
        physics.step(1.0 / 60.0);
      }
      // World anchor on bob must stay locked at pivot `(0, 5, 0)`!
      final worldBobAnchor = bob.bodyWorldMatrix.transformed3(
        Vector3(-2, 0, 0),
      );
      expect(worldBobAnchor.distanceTo(pivot.position), lessThan(0.03));
      // Pendulum swung downward under gravity!
      expect(bob.position.y, lessThan(4.8));

      // HingeJoint3D with twist limits `[-pi/6 .. +pi/4]` around Z axis.
      final hingeWorld = PhysicsWorld3D(
        gravity: Vector3(0, -9.81, 0),
        velocityIterations: 12,
        positionIterations: 6,
      );
      final frame = RigidBody3D(
        bodyType: BodyType3D.static,
        shape: BoxShape3D(halfExtents: Vector3.all(0.2)),
        position: Vector3(0, 3, 0),
      );
      final arm = RigidBody3D(
        shape: BoxShape3D(halfExtents: Vector3(1.0, 0.15, 0.15)),
        position: Vector3(1.0, 3.0, 0.0),
        angularDamping: 0.4,
        canSleep: false,
      );
      const minLim = -math.pi / 4;
      const maxLim = math.pi / 6;
      final hinge = HingeJoint3D(
        bodyA: frame,
        bodyB: arm,
        localAnchorA: Vector3.zero(),
        localAnchorB: Vector3(-1.0, 0, 0),
        localAxisA: Vector3(0, 0, 1),
        minAngle: minLim,
        maxAngle: maxLim,
      );
      hingeWorld
        ..addBody(frame)
        ..addBody(arm)
        ..addJoint(hinge);

      for (var i = 0; i < 120; i++) {
        hingeWorld.step(1.0 / 60.0);
      }
      // Gravity pulls the arm clockwise (`-Z` torque -> negative angle),
      // clamping right at `minLim = -pi/4`!
      expect(hinge.jointAngle, closeTo(minLim, 0.06));
      expect(arm.position.z.abs(), lessThan(0.02));
    });

    test('throwDice3D produces bit-identical deterministic trajectories', () {
      (Vector3, Quaternion, Vector3, Quaternion) simulateThrow(int seed) {
        final world = PhysicsWorld3D();
        final tray = RigidBody3D(
          bodyType: BodyType3D.static,
          shape: BoxShape3D(halfExtents: Vector3(8, 0.5, 8)),
          position: Vector3(0, -0.5, 0),
          friction: 0.6,
          restitution: 0.35,
        );
        final dieA = RigidBody3D(
          shape: BoxShape3D(halfExtents: Vector3.all(0.25)),
          friction: 0.6,
          restitution: 0.35,
        );
        final dieB = RigidBody3D(
          shape: BoxShape3D(halfExtents: Vector3.all(0.25)),
          friction: 0.6,
          restitution: 0.35,
        );
        world
          ..addBody(tray)
          ..addBody(dieA)
          ..addBody(dieB)
          ..throwDice3D([dieA, dieB], seed: seed);

        for (var tick = 0; tick < 180; tick++) {
          world.step(1.0 / 60.0);
        }
        return (
          dieA.position.clone(),
          dieA.rotation.clone(),
          dieB.position.clone(),
          dieB.rotation.clone(),
        );
      }

      final run1 = simulateThrow(20261118);
      final run2 = simulateThrow(20261118);
      final runDifferent = simulateThrow(99999999);

      expect(run1.$1.x, equals(run2.$1.x));
      expect(run1.$1.y, equals(run2.$1.y));
      expect(run1.$1.z, equals(run2.$1.z));
      expect(run1.$2.x, equals(run2.$2.x));
      expect(run1.$2.y, equals(run2.$2.y));
      expect(run1.$2.z, equals(run2.$2.z));
      expect(run1.$2.w, equals(run2.$2.w));
      expect(run1.$3.x, equals(run2.$3.x));
      expect(run1.$4.w, equals(run2.$4.w));

      expect(run1.$1.distanceTo(runDifferent.$1), greaterThan(0.05));
    });

    test('DistanceJoint3D rod & RigidBody3D parent MeshComponent sync', () {
      final world = PhysicsWorld3D();
      final ceiling = RigidBody3D(
        bodyType: BodyType3D.static,
        shape: SphereShape3D(radius: 0.1),
        position: Vector3(0, 6, 0),
      );
      final body = RigidBody3D(
        shape: BoxShape3D(halfExtents: Vector3.all(0.3)),
        canSleep: false,
      );
      final cubeMesh = MeshComponent(
        mesh: CuboidMesh(size: Vector3.all(0.6)),
        position: Vector3(1.5, 6, 0),
        children: [body],
      );
      final rod = DistanceJoint3D(
        bodyA: ceiling,
        bodyB: body,
        length: 1.5,
      );
      world
        ..addBody(ceiling)
        ..addBody(body)
        ..addJoint(rod);

      for (var i = 0; i < 60; i++) {
        world.step(1.0 / 60.0);
      }

      // Parent MeshComponent position was synchronized and stayed at distance
      // `1.5m` from the ceiling anchor!
      expect(
        cubeMesh.position.distanceTo(ceiling.position),
        closeTo(1.5, 0.03),
      );
      expect(cubeMesh.position.y, lessThan(5.8));
    });
  });
}
