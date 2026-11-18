import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flame_3d/audio.dart';
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/model.dart';
import 'package:flame_3d/navigation.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NavMesh3D portal adjacency, 3D funnel & bridge elevation', () {
    test(
      'navigates around an obstacle hole and over a 3D bridge/ramp with '
      'funnel string-pulling shorter than raw triangle centroids',
      () {
        // Build a custom mesh with:
        // 1) A 3x3 ring of ground quads around a central hole `[0..2] x [0..2]`
        //    (8 walkable quads = 16 triangles, center quad `[0..2, 0..2]`
        //    omitted as an impassable pit/obstacle!), PLUS
        // 2) A ramp `[0..2] x [6..8]` rising from `y = 0` to `y = 2` and an
        //    elevated bridge deck `[0..2] x [8..12]` at `y = 2`, plus a steep
        //    vertical wall (`90 deg`) that must be rejected!
        final verts = <Vertex>[];
        final indices = <int>[];

        void addQuad(
          Vector3 p00,
          Vector3 p10,
          Vector3 p11,
          Vector3 p01,
        ) {
          final base = verts.length;
          verts
            ..add(Vertex(position: p00, texCoord: Vector2.zero()))
            ..add(Vertex(position: p10, texCoord: Vector2.zero()))
            ..add(Vertex(position: p11, texCoord: Vector2.zero()))
            ..add(Vertex(position: p01, texCoord: Vector2.zero()));
          // CCW when viewed from +Y: `(p00, p01, p11)` and `(p00, p11, p10)`.
          indices.addAll([
            base,
            base + 3,
            base + 2,
            base,
            base + 2,
            base + 1,
          ]);
        }

        // 3x3 grid of 2x2m cells over `[-2..4] x [0..6]`, skipping the center
        // hole `[0..2] x [2..4]`.
        for (var gx = 0; gx < 3; gx++) {
          for (var gz = 0; gz < 3; gz++) {
            if (gx == 1 && gz == 1) {
              continue; // Obstacle hole!
            }
            final x0 = -2.0 + gx * 2.0;
            final x1 = x0 + 2.0;
            final z0 = gz * 2.0;
            final z1 = z0 + 2.0;
            addQuad(
              Vector3(x0, 0, z0),
              Vector3(x1, 0, z0),
              Vector3(x1, 0, z1),
              Vector3(x0, 0, z1),
            );
          }
        }

        // Sloped ramp `[0..2] x [6..10]` rising `2m` over `4m` (`~26.5 deg`
        // `< maxSlopeAngleRad = 0.8 rad ~ 45.8 deg`).
        addQuad(
          Vector3(0, 0, 6),
          Vector3(2, 0, 6),
          Vector3(2, 2, 10),
          Vector3(0, 2, 10),
        );

        // Elevated bridge deck `[0..2] x [10..14]` at `y = 2`.
        addQuad(
          Vector3(0, 2, 10),
          Vector3(2, 2, 10),
          Vector3(2, 2, 14),
          Vector3(0, 2, 14),
        );

        // Non-walkable vertical cliff wall (normal along +X, `cosSlope == 0`).
        addQuad(
          Vector3(2, 0, 10),
          Vector3(2, 2, 10),
          Vector3(2, 2, 14),
          Vector3(2, 0, 14),
        );

        final mesh = Mesh()
          ..addSurface(Surface(vertices: verts, indices: indices));
        final navMesh = NavMesh3D.fromMesh(mesh);

        // 8 ground quads + 1 ramp + 1 bridge = 10 quads = 20 walkable triangles
        // (the 2 vertical wall triangles were filtered out!).
        expect(navMesh.polyCount, 20);

        // Off-mesh point inside the central pit `(1, 0, 3)` clamps onto the
        // hole boundary!
        final clamped = navMesh.findNearestPoly(Vector3(1.0, 0.0, 3.0));
        expect(clamped, isNotNull);
        expect(clamped!.distanceSquared, greaterThan(0.5));

        // Path from south of the hole `(1, 0, 0.5)` to the elevated bridge
        // `(1, 2, 13.0)`.
        final start = Vector3(1.0, 0.0, 0.5);
        final goal = Vector3(1.0, 2.0, 13.0);
        final funnelPath = navMesh.findPath(start, goal);
        final centroidPath = navMesh.findCentroidPath(start, goal);

        expect(funnelPath.length, greaterThanOrEqualTo(4));
        expect(funnelPath.first.distanceTo(start), lessThan(1e-4));
        expect(funnelPath.last.distanceTo(goal), lessThan(1e-4));

        double pathLength(List<Vector3> pts) {
          var sum = 0.0;
          for (var i = 0; i < pts.length - 1; i++) {
            sum += pts[i].distanceTo(pts[i + 1]);
          }
          return sum;
        }

        final funnelLen = pathLength(funnelPath);
        final centroidLen = pathLength(centroidPath);
        // Funnel string-pulling produces a significantly shorter taut path than
        // zig-zagging through triangle centroids!
        expect(funnelLen, lessThan(centroidLen - 0.5));

        // Verify elevation sampling on ground, mid-ramp, and elevated bridge!
        expect(
          navMesh.sampleHeightAt(Vector3(1.0, 0.0, 1.0)),
          closeTo(0.0, 1e-4),
        );
        expect(
          navMesh.sampleHeightAt(Vector3(1.0, 1.0, 8.0)),
          closeTo(1.0, 1e-3),
        );
        expect(
          navMesh.sampleHeightAt(Vector3(1.0, 2.0, 12.0)),
          closeTo(2.0, 1e-4),
        );

        // Also builds seamlessly from `TerrainMesh3D.procedural`.
        final terrain = TerrainMesh3D.procedural(
          columns: 12,
          rows: 12,
          width: 10.0,
          depth: 10.0,
          amplitude: 0.6,
        );
        final terrainNav = NavMesh3D.fromMesh(terrain);
        expect(terrainNav.polyCount, greaterThan(100));
        final tPath = terrainNav.findPath(
          Vector3(-3, 0, -3),
          Vector3(3, 0, 3),
        );
        expect(tPath.length, greaterThanOrEqualTo(2));
      },
    );
  });

  group('CrowdSteering3D multi-agent avoidance', () {
    test('two head-on agents separate cleanly without overlapping', () {
      final agentA = CrowdAgent3D(
        position: Vector3(-4.0, 0.0, 0.0),
        radius: 0.45,
        maxSpeed: 3.0,
      )..setPath([Vector3(-4.0, 0.0, 0.0), Vector3(4.0, 0.0, 0.0)]);

      final agentB = CrowdAgent3D(
        position: Vector3(4.0, 0.0, 0.0),
        radius: 0.45,
        maxSpeed: 3.0,
      )..setPath([Vector3(4.0, 0.0, 0.0), Vector3(-4.0, 0.0, 0.0)]);

      final crowd = CrowdSteering3D(agents: [agentA, agentB]);

      var minCenterDist = double.infinity;
      var maxLateralDeflection = 0.0;

      for (var step = 0; step < 260; step++) {
        crowd.update(1.0 / 60.0);
        final d = agentA.position.distanceTo(agentB.position);
        if (d < minCenterDist) {
          minCenterDist = d;
        }
        maxLateralDeflection = math.max(
          maxLateralDeflection,
          agentA.position.z.abs(),
        );
      }

      // Combined radius is `0.45 + 0.45 = 0.90m`: agents never overlapped!
      expect(minCenterDist, greaterThanOrEqualTo(0.89));
      expect(maxLateralDeflection, greaterThan(0.35));
      // Both agents reached their opposite goals cleanly!
      expect(
        agentA.position.distanceTo(Vector3(4.0, 0.0, 0.0)),
        lessThan(0.25),
      );
      expect(
        agentB.position.distanceTo(Vector3(-4.0, 0.0, 0.0)),
        lessThan(0.25),
      );
    });
  });

  group('SpatialAudioListener3D & SpatialAudioEmitter3D', () {
    test(
      'computes stereo pan, distance falloff, directional cone, wall raycast '
      'occlusion, Doppler pitch, and BoneSocket3D attachment',
      () async {
        final camera = CameraComponent3D(
          position: Vector3.zero(),
          target: Vector3(0, 0, -5),
          up: Vector3(0, 1, 0),
        );
        final listener = SpatialAudioListener3D(
          camera: camera,
          autoComputeVelocity: false,
        );

        final leftEmitter = SpatialAudioEmitter3D(
          position: Vector3(-4, 0, -1),
          maxDistance: 20.0,
          autoComputeVelocity: false,
        );
        final rightFarEmitter = SpatialAudioEmitter3D(
          position: Vector3(10, 0, 0),
          maxDistance: 20.0,
          autoComputeVelocity: false,
        );

        // 1. Stereo left/right pan & distance attenuation.
        final leftMix = leftEmitter.evaluateMix(listener);
        final rightMix = rightFarEmitter.evaluateMix(listener);
        expect(leftMix.pan, lessThan(-0.9));
        expect(rightMix.pan, closeTo(1.0, 1e-4));
        expect(rightMix.volume, lessThan(leftMix.volume));

        // 2. Directional sound cone (`inner = pi/3`, `outer = pi/2`,
        // `outerConeGain = 0.2`): emitter at `(0, 0, -5)` facing `(0, 0, -1)`
        // puts listener at `(0, 0, 0)` directly behind the cone (`angle = pi`).
        final coneEmitter = SpatialAudioEmitter3D(
          position: Vector3(0, 0, -5),
          minDistance: 5.0,
          innerConeRad: math.pi / 3,
          outerConeRad: math.pi / 2,
          outerConeGain: 0.2,
          localForward: Vector3(0, 0, -1),
          autoComputeVelocity: false,
        );
        final behindConeMix = coneEmitter.evaluateMix(listener);
        expect(behindConeMix.volume, closeTo(0.2, 1e-4));

        // Rotate emitter 180 deg around Y to face `+Z` (directly at listener!).
        coneEmitter.rotation.setFrom(
          Quaternion.axisAngle(Vector3(0, 1, 0), math.pi),
        );
        final frontConeMix = coneEmitter.evaluateMix(listener);
        expect(frontConeMix.volume, closeTo(1.0, 1e-4));

        // 3. Wall raycast occlusion via `World3D.raycast`.
        final wall = MeshComponent(
          mesh: CuboidMesh(size: Vector3(6, 6, 0.5)),
          position: Vector3(0, 0, -2.5),
        );
        final occludedEmitter = SpatialAudioEmitter3D(
          position: Vector3(0, 0, -6),
          minDistance: 6.0,
          enableOcclusion: true,
          occlusionGain: 0.3,
          autoComputeVelocity: false,
        );
        final world = World3D(children: [listener, wall, occludedEmitter]);
        final occMix = occludedEmitter.evaluateMix(listener, world: world);
        expect(occMix.occluded, isTrue);
        expect(occMix.volume, closeTo(0.3, 1e-4));

        // Move wall aside -> unoccluded!
        wall.position.setValues(20, 0, -2.5);
        final clearMix = occludedEmitter.evaluateMix(listener, world: world);
        expect(clearMix.occluded, isFalse);
        expect(clearMix.volume, closeTo(1.0, 1e-4));

        // 4. Doppler pitch shift: emitter at `(0, 0, -10)` approaching listener
        // (`+Z` velocity `+34.3 m/s`) vs receding (`-34.3 m/s`).
        occludedEmitter.velocity.setValues(0, 0, 34.3);
        final approachingMix = occludedEmitter.evaluateMix(
          listener,
          world: world,
        );
        expect(approachingMix.pitch, closeTo(343.0 / (343.0 - 34.3), 1e-3));
        expect(approachingMix.pitch, greaterThan(1.0));

        occludedEmitter.velocity.setValues(0, 0, -34.3);
        final recedingMix = occludedEmitter.evaluateMix(listener, world: world);
        expect(recedingMix.pitch, closeTo(343.0 / (343.0 + 34.3), 1e-3));
        expect(recedingMix.pitch, lessThan(1.0));

        // 5. Emitter mounted inside a `BoneSocket3D` updates automatically!
        final handNode = ModelNode(
          name: 'Hand.R',
          nodeIndex: 0,
          parentNodeIndex: null,
          transform: Matrix4.translationValues(3, 0, 0),
          mesh: CuboidMesh(size: Vector3.all(0.1)),
          joints: {},
        );
        SpatialMix3D? callbackMix;
        final socketEmitter = SpatialAudioEmitter3D(
          onMixChanged: (m) => callbackMix = m,
        );
        final modelComp = ModelComponent(
          model: Model(nodes: {0: handNode}, animations: []),
          children: [
            BoneSocket3D.byName('Hand.R', children: [socketEmitter]),
          ],
        );
        final gameWorld = World3D(children: [listener, modelComp]);
        final game = FlameGame(world: gameWorld);
        await game.onLoad();
        game.update(1.0 / 60.0);

        expect(callbackMix, isNotNull);
        expect(callbackMix!.pan, closeTo(1.0, 1e-3));

        // 6. Linear and exponential attenuation models.
        final linEmitter = SpatialAudioEmitter3D(
          position: Vector3(0, 0, -5.5),
          maxDistance: 10.0,
          attenuationModel: AudioAttenuationModel3D.linear,
          autoComputeVelocity: false,
        );
        expect(linEmitter.evaluateMix(listener).volume, closeTo(0.5, 1e-4));

        final expEmitter = SpatialAudioEmitter3D(
          position: Vector3(0, 0, -4.0),
          minDistance: 2.0,
          rolloff: 2.0,
          attenuationModel: AudioAttenuationModel3D.exponential,
          autoComputeVelocity: false,
        );
        expect(expEmitter.evaluateMix(listener).volume, closeTo(0.25, 1e-4));
      },
    );
  });
}
