import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flame/game.dart';
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/collisions.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/model.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Shape3D & Narrowphase3D manifolds', () {
    test('Sphere, Capsule, OBB, and ConvexHull compute exact manifolds', () {
      final sphereA = SphereShape3D(radius: 1.0);
      final sphereB = SphereShape3D(radius: 0.75);
      final mA = Matrix4.translationValues(0, 0, 0);
      final mB = Matrix4.translationValues(1.25, 0, 0);

      final ss = Narrowphase3D.test(sphereA, mA, sphereB, mB);
      expect(ss, isNotNull);
      expect(ss!.normal.x, closeTo(1.0, 1e-5));
      expect(ss.penetrationDepth, closeTo(0.5, 1e-5));
      expect(ss.contactPointA.x, closeTo(1.0, 1e-5));
      expect(ss.contactPointB.x, closeTo(0.5, 1e-5));

      // Capsule vs Sphere.
      final cap = CapsuleShape3D(radius: 0.5, height: 3.0);
      final capMat = Matrix4.translationValues(0, 0, 0);
      final sphNearTop = Matrix4.translationValues(0.8, 1.0, 0);
      final cs = Narrowphase3D.test(cap, capMat, sphereA, sphNearTop);
      expect(cs, isNotNull);
      expect(cs!.normal.x, closeTo(1.0, 1e-4));
      expect(cs.penetrationDepth, closeTo(0.7, 1e-4));

      // Rotated OBB vs Sphere & Rotated OBB vs OBB (15-axis SAT).
      final obb = BoxShape3D(halfExtents: Vector3(1.0, 0.5, 1.0));
      final rot45 = Matrix4.compose(
        Vector3.zero(),
        Quaternion.axisAngle(Vector3(0, 1, 0), math.pi / 4),
        Vector3.all(1.0),
      );
      final sphAbove = Matrix4.translationValues(0, 1.2, 0);
      final sb = Narrowphase3D.test(obb, rot45, sphereA, sphAbove);
      expect(sb, isNotNull);
      expect(sb!.normal.y, closeTo(1.0, 1e-4));
      expect(sb.penetrationDepth, closeTo(0.3, 1e-4));

      final obbTop = Matrix4.translationValues(0, 0.9, 0);
      final bb = Narrowphase3D.test(obb, rot45, obb, obbTop);
      expect(bb, isNotNull);
      expect(bb!.normal.y, closeTo(1.0, 1e-4));
      expect(bb.penetrationDepth, closeTo(0.1, 1e-4));
      expect(bb.contacts.length, greaterThanOrEqualTo(3));

      // ConvexHull tetrahedron/wedge vs Box via GJK + EPA.
      final pyramid = ConvexHullShape3D(
        vertices: [
          Vector3(-1, 0, -1),
          Vector3(1, 0, -1),
          Vector3(1, 0, 1),
          Vector3(-1, 0, 1),
          Vector3(0, 2, 0),
        ],
      );
      final hullMat = Matrix4.identity();
      final boxAtTip = Matrix4.translationValues(0, 2.3, 0);
      final hb = Narrowphase3D.test(pyramid, hullMat, obb, boxAtTip);
      expect(hb, isNotNull);
      expect(hb!.penetrationDepth, closeTo(0.2, 1e-2));
      expect(hb.normal.y, greaterThan(0.9));

      // Separated shapes return null.
      final farMat = Matrix4.translationValues(0, 5.0, 0);
      expect(Narrowphase3D.test(pyramid, hullMat, obb, farMat), isNull);
    });

    test('intersectShapeWithSurfaceBvh queries triangles in O(log T)', () {
      final terrain = TerrainMesh3D(
        columns: 9,
        rows: 9,
        width: 8.0,
        depth: 8.0,
        heights: Float32List(81),
      );
      final surface = terrain.surfaces.first;
      final sphere = SphereShape3D(radius: 0.5);

      final hitMat = Matrix4.translationValues(1.0, 0.3, -1.0);
      final manifold = Narrowphase3D.intersectShapeWithSurfaceBvh(
        sphere,
        hitMat,
        surface,
        Matrix4.identity(),
      );
      expect(manifold, isNotNull);
      expect(manifold!.penetrationDepth, closeTo(0.2, 1e-4));
      expect(manifold.normal.y, closeTo(-1.0, 1e-4));

      final missMat = Matrix4.translationValues(1.0, 0.8, -1.0);
      expect(
        Narrowphase3D.intersectShapeWithSurfaceBvh(
          sphere,
          missMat,
          surface,
          Matrix4.identity(),
        ),
        isNull,
      );
    });
  });

  group('CollisionSystem3D masks, callbacks & TriggerVolume3D', () {
    test(
      '32-bit layer/mask filtering, start/stay/end & trigger enter/exit',
      () async {
        final system = CollisionSystem3D(autoStep: false);
        final actor = _TrackedEntity(
          position: Vector3(0, 0, 0),
          collider: Collider3D(
            shape: SphereShape3D(radius: 0.6),
            collisionMask: 0x02 | 0x04,
          ),
        );
        final ignoredObstacle = _TrackedEntity(
          position: Vector3(0.2, 0, 0),
          collider: Collider3D(
            shape: SphereShape3D(radius: 0.6),
            collisionLayer: 0x08, // Not in actor's mask!
          ),
        );
        final solidWall = _TrackedEntity(
          position: Vector3(0.8, 0, 0),
          collider: Collider3D(
            shape: BoxShape3D(halfExtents: Vector3.all(0.5)),
            collisionLayer: 0x02,
            collisionMask: 0x01,
            isStatic: true,
          ),
        );

        var triggerEnters = 0;
        var triggerStays = 0;
        var triggerExits = 0;
        final zone = TriggerVolume3D(
          shape: BoxShape3D(halfExtents: Vector3.all(1.0)),
          position: Vector3(0, 0, 0),
          collisionLayer: 0x04,
          collisionMask: 0x01,
          onEnter3D: (_, _) => triggerEnters++,
          onStay3D: (_, _) => triggerStays++,
          onExit3D: (_) => triggerExits++,
        );

        final world = World3D(
          children: [system, actor, ignoredObstacle, solidWall, zone],
        );
        final game = FlameGame(world: world);
        await game.onLoad();
        game.update(0);

        // Step 1: enters both solidWall and zone, ignores ignoredObstacle.
        system.step();
        expect(actor.starts, 2);
        expect(actor.stays, 0);
        expect(actor.ends, 0);
        expect(ignoredObstacle.starts, 0);
        expect(triggerEnters, 1);
        expect(triggerStays, 0);

        // Step 2: staying in contact.
        system.step();
        expect(actor.starts, 2);
        expect(actor.stays, 2);
        expect(triggerEnters, 1);
        expect(triggerStays, 1);

        // Step 3: move actor outside both volumes.
        actor.position.setValues(-10, 0, 0);
        system.step();
        expect(actor.ends, 2);
        expect(triggerExits, 1);

        // Raycast colliders honoring masks & trigger toggle.
        final ray = Ray.originDirection(Vector3(-5, 0, 0), Vector3(1, 0, 0));
        final rayNoTrig = system.raycastColliders(
          ray,
          collisionMask: 0x02 | 0x04,
          includeTriggers: false,
        );
        expect(rayNoTrig, isNotNull);
        expect(rayNoTrig!.collider, same(solidWall.collider));
      },
    );
  });

  group('BoneHitbox3D & SkinnedHitboxRig3D posed skeletal raycasting', () {
    test('tracks animated head & curled multi-bone chain accurately', () {
      // Build a 6-bone articulated serpent/character spine where rest pose
      // sits along +Y, and animation curls the tip sideways to (+4, 1, 0).
      final nodes = <int, ModelNode>{};
      final animNodes = <int, NodeAnimation>{};
      for (var i = 0; i < 6; i++) {
        nodes[i] = ModelNode(
          name: i == 5 ? 'Head' : 'Spine_$i',
          nodeIndex: i,
          parentNodeIndex: i == 0 ? null : i - 1,
          transform: Matrix4.translationValues(0, 0.5, 0),
          mesh: CuboidMesh(size: Vector3.all(0.1)),
          joints: {},
        );
        animNodes[i] = NodeAnimation(
          channels: [
            AnimationController(
              animation: TranslationAnimationSpline.from(
                interpolation: AnimationInterpolation.linear,
                times: [0.0, 1.0],
                values: [Vector3(0, 0.5, 0), Vector3(0.75, 0.15, 0)],
              ),
            ),
          ],
        );
      }

      final curlClip = ModelAnimation(name: 'curl', nodes: animNodes);
      final model = Model(nodes: nodes, animations: [curlClip]);
      final rig = SkinnedHitboxRig3D(
        hitboxes: [
          for (var i = 0; i < 6; i++)
            BoneHitbox3D.byName(
              i == 5 ? 'Head' : 'Spine_$i',
              shape: SphereShape3D(radius: 0.25),
              damageMultiplier: i == 5 ? 2.5 : 1.0,
            ),
        ],
      );
      final character = ModelComponent(
        model: model,
        position: Vector3(0, 0, 0),
        children: [rig],
      );

      // In rest pose (t = 0), Head is at `(0, 3.0, 0)`.
      final restHeadRay = Ray.originDirection(
        Vector3(0, 3.0, 5),
        Vector3(0, 0, -1),
      );
      final restHit = rig.raycast(restHeadRay);
      expect(restHit, isNotNull);
      expect(restHit!.boneName, 'Head');
      expect(restHit.nodeIndex, 5);
      expect(restHit.hitbox.damageMultiplier, 2.5);

      // Advance animation to `t = 1.0`: Head curls to `(6 * 0.75, 6 * 0.15, 0)`
      // = `(4.5, 0.9, 0)`!
      character.playAnimationByName('curl', mode: AnimationPlayMode.once);
      character.update(1.0);

      // Old rest-pose ray at `(0, 3.0, ...)` now cleanly MISSES!
      expect(rig.raycast(restHeadRay), isNull);

      // Ray aimed at the posed curled Head `(4.5, 0.9, 0)` HITS!
      final posedHeadRay = Ray.originDirection(
        Vector3(4.5, 0.9, 5),
        Vector3(0, 0, -1),
      );
      final posedHit = rig.raycast(posedHeadRay);
      expect(posedHit, isNotNull);
      expect(posedHit!.boneName, 'Head');
      expect(posedHit.distance, closeTo(4.75, 1e-3));
      expect(posedHit.normal.z, closeTo(1.0, 1e-3));
    });
  });

  group('ShapeCast3D & KinematicCharacterController3D', () {
    test('sphereCast and capsuleCast compute exact swept TOI', () {
      final system = CollisionSystem3D();
      final wall = Collider3D(
        shape: BoxShape3D(halfExtents: Vector3(1, 2, 1)),
        position: Vector3(5, 0, 0),
        isStatic: true,
      );
      system.register(wall);

      // Sphere radius 0.5 at x=0 sweeping +10 along X hits wall front (x=4) at
      // center x=3.5 -> toi = 3.5 / 10 = 0.35.
      final sHit = ShapeCast3D.sphereCast(
        origin: Vector3.zero(),
        radius: 0.5,
        delta: Vector3(10, 0, 0),
        collisionSystem: system,
      );
      expect(sHit, isNotNull);
      expect(sHit!.toi, closeTo(0.35, 1e-3));
      expect(sHit.distance, closeTo(3.5, 1e-3));
      expect(sHit.normal.x, closeTo(-1.0, 1e-3));
      expect(sHit.collider, same(wall));

      // Capsule cast against a World3D MeshComponent.
      final meshWall = MeshComponent(
        mesh: CuboidMesh(size: Vector3(2, 4, 2)),
        position: Vector3(0, 0, -6),
      );
      final world = World3D(children: [meshWall]);
      final cHit = ShapeCast3D.capsuleCast(
        origin: Vector3.zero(),
        radius: 0.5,
        height: 2.0,
        delta: Vector3(0, 0, -10),
        world: world,
      );
      expect(cHit, isNotNull);
      // Wall front is z = -5, capsule radius = 0.5 -> center stops at z = -4.5
      // -> toi = 0.45!
      expect(cHit!.toi, closeTo(0.45, 1e-3));
      expect(cHit.normal.z, closeTo(1.0, 1e-3));
      expect(cHit.component, same(meshWall));
    });

    test(
      'KinematicCharacterController3D climbs stairs, slides along walls, '
      'blocks steep cliffs, and walks over TerrainMesh3D',
      () {
        final system = CollisionSystem3D();
        // Flat floor top at y = 0 (`position.y = -0.5`, `hy = 0.5`).
        final floor = Collider3D(
          shape: BoxShape3D(halfExtents: Vector3(20, 0.5, 20)),
          position: Vector3(0, -0.5, 0),
          isStatic: true,
        );
        // Stair step of height 0.25 (`<= stepOffset = 0.35`) starting at x = 1:
        // box `hx = 1, hy = 0.125`, center `(2, 0.125, 0)` -> top `y = 0.25`.
        final lowStep = Collider3D(
          shape: BoxShape3D(halfExtents: Vector3(1.0, 0.125, 2.0)),
          position: Vector3(2.0, 0.125, 0),
          isStatic: true,
        );
        system
          ..register(floor)
          ..register(lowStep);

        final controller = KinematicCharacterController3D();
        final player = _DummyActor(
          position: Vector3(0.0, 0.92, 0.0),
          children: [controller],
        );

        // Settle onto floor and walk +X up onto the 0.25m stair step.
        for (var i = 0; i < 40; i++) {
          controller.moveAndSlide(
            Vector3(3.0, -4.0, 0.0),
            1.0 / 60.0,
            collisionSystem: system,
          );
        }
        expect(controller.isGrounded, isTrue);
        expect(player.position.x, greaterThan(1.3));
        // Capsule bottom (`y - 0.9`) climbed onto `y = 0.25`!
        expect(player.position.y, closeTo(0.25 + 0.9 + 0.02, 0.04));

        // 2. Diagonal wall slide: angled vertical wall at 45 deg in XZ.
        final wallSys = CollisionSystem3D()..register(floor);
        final diagWall = Collider3D(
          shape: BoxShape3D(halfExtents: Vector3(0.2, 2.0, 4.0)),
          position: Vector3(2.0, 1.0, 0.0),
          rotation: Quaternion.axisAngle(Vector3(0, 1, 0), math.pi / 4),
          isStatic: true,
        );
        wallSys.register(diagWall);

        player.position.setValues(0.0, 0.92, 0.0);
        for (var i = 0; i < 45; i++) {
          controller.moveAndSlide(
            Vector3(4.0, -2.0, 0.0),
            1.0 / 60.0,
            collisionSystem: wallSys,
          );
        }
        // Instead of snagging at z = 0, character slid smoothly along Z!
        expect(player.position.z.abs(), greaterThan(0.5));

        // 3. Steep cliff (`65 deg > maxSlopeAngleRad ~ 46 deg`) blocks climb!
        final cliffSys = CollisionSystem3D()..register(floor);
        final steepCliff = Collider3D(
          shape: BoxShape3D(halfExtents: Vector3(0.2, 3.0, 3.0)),
          position: Vector3(2.2, 1.2, 0.0),
          rotation: Quaternion.axisAngle(
            Vector3(0, 0, 1),
            25 * math.pi / 180.0, // Face normal tilted 65 deg from +Y!
          ),
          isStatic: true,
        );
        cliffSys.register(steepCliff);

        player.position.setValues(0.0, 0.92, 0.0);
        for (var i = 0; i < 60; i++) {
          controller.moveAndSlide(
            Vector3(4.0, -5.0, 0.0),
            1.0 / 60.0,
            collisionSystem: cliffSys,
          );
        }
        // Blocked from climbing up the 65 deg cliff!
        expect(player.position.y, lessThan(1.15));

        // 4. Walking smoothly over a procedural `TerrainMesh3D` hill!
        final hillTerrain = TerrainMesh3D.procedural(
          columns: 24,
          rows: 24,
          width: 16.0,
          depth: 16.0,
          amplitude: 0.8,
          frequency: 0.35,
        );
        final terrainComp = MeshComponent(mesh: hillTerrain);
        final startH = hillTerrain.sampleHeight(-3.0, 0.0);
        player.position.setValues(-3.0, startH + 0.95, 0.0);

        for (var i = 0; i < 60; i++) {
          controller.moveAndSlide(
            Vector3(3.0, -6.0, 0.0),
            1.0 / 60.0,
            staticGeometry: [terrainComp],
          );
        }
        expect(controller.isGrounded, isTrue);
        expect(player.position.x, greaterThan(-0.5));
        final endGroundH = hillTerrain.sampleHeight(
          player.position.x,
          player.position.z,
        );
        expect(player.position.y - 0.9, closeTo(endGroundH, 0.12));

        // 5. Z-up (`Axis3D.z`) + tall step (`> stepOffset`) block.
        final zSys = CollisionSystem3D()
          ..register(
            Collider3D(
              shape: BoxShape3D(halfExtents: Vector3(10, 10, 0.5)),
              position: Vector3(0, 0, -0.5),
              isStatic: true,
            ),
          )
          ..register(
            Collider3D(
              shape: BoxShape3D(halfExtents: Vector3(1.0, 2.0, 0.6)),
              // 1.2m tall > stepOffset 0.35m!
              position: Vector3(2.0, 0.0, 0.6),
              isStatic: true,
            ),
          );
        final zCtrl = KinematicCharacterController3D(upAxis: Axis3D.z);
        final zActor = _DummyActor(
          position: Vector3(0.0, 0.0, 0.92),
          children: [zCtrl],
        );
        for (var i = 0; i < 30; i++) {
          zCtrl.moveAndSlide(
            Vector3(3.0, 0.0, -4.0),
            1.0 / 60.0,
            collisionSystem: zSys,
          );
        }
        expect(zCtrl.isGrounded, isTrue);
        expect(zCtrl.groundNormal.z, closeTo(1.0, 1e-3));
        // Blocked before the 1.2m wall at x = 1.0 (`x ~ 0.58`).
        expect(zActor.position.x, lessThan(0.65));
      },
    );
  });
}

class _DummyActor({super.position, super.children}) extends Component3D;

class _TrackedEntity({
  required final Collider3D collider,
  super.position,
}) extends Component3D with CollisionCallbacks3D {
  this : super(children: [collider]);

  int starts = 0;
  int stays = 0;
  int ends = 0;

  @override
  void onCollisionStart3D(Collider3D other, CollisionManifold3D manifold) {
    starts++;
  }

  @override
  void onCollision3D(Collider3D other, CollisionManifold3D manifold) {
    stays++;
  }

  @override
  void onCollisionEnd3D(Collider3D other) {
    ends++;
  }
}
