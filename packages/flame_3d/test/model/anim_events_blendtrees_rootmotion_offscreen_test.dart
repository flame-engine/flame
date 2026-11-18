import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flame_3d/camera.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/model.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_fakes/fake_gpu_backend.dart';

void main() {
  ModelAnimation buildTranslationClip(
    String name, {
    required double duration,
    required Vector3 start,
    required Vector3 end,
    int nodeIndex = 0,
    List<AnimationEvent3D> events = const [],
    MorphWeightsChannel? morphWeights,
  }) {
    return ModelAnimation(
      name: name,
      events: events,
      nodes: {
        nodeIndex: NodeAnimation(
          channels: [
            AnimationController(
              animation: TranslationAnimationSpline.from(
                interpolation: AnimationInterpolation.linear,
                times: [0.0, duration],
                values: [start, end],
              ),
            ),
          ],
          morphWeights: morphWeights,
        ),
      },
    );
  }

  group('AnimationEvent3D firing across once, loop, pingPong & layers', () {
    test('fires events in once and loop wrap-around without duplicates', () {
      final clip = buildTranslationClip(
        'stride',
        duration: 1.0,
        start: Vector3.zero(),
        end: Vector3(2, 0, 0),
        events: [
          AnimationEvent3D(name: 'start', time: 0.0, payload: 0),
          AnimationEvent3D(name: 'left_foot', time: 0.3, payload: 1),
          AnimationEvent3D(name: 'right_foot', time: 0.8, payload: 2),
          AnimationEvent3D(name: 'end', time: 1.0, payload: 3),
        ],
      );

      final fired = <String>[];
      final state = AnimationState()
        ..addEventListener((e) => fired.add('${e.name}:${e.payload}'))
        ..startAnimation(clip);

      // Tick 1: [0.0 .. 0.5] -> fires `start` (0.0) and `left_foot` (0.3).
      state.update(0.5);
      expect(fired, ['start:0', 'left_foot:1']);

      // Tick 2: (0.5 .. 1.0] + wrap [0.0 .. 0.35] (`dt = 0.85`).
      fired.clear();
      state.update(0.85);
      expect(
        fired,
        ['right_foot:2', 'end:3', 'start:0', 'left_foot:1'],
      );

      // Exact boundary hit (0.35 -> 1.0) followed by wrap (1.0 -> 0.2) must
      // never double-fire `end:3`.
      fired.clear();
      state.update(0.65);
      expect(fired, ['right_foot:2', 'end:3']);

      fired.clear();
      state.update(0.2);
      expect(fired, ['start:0']);
    });

    test('fires pingPong forward & backward without apex double-firing', () {
      final clip = buildTranslationClip(
        'swing',
        duration: 1.0,
        start: Vector3.zero(),
        end: Vector3(1, 0, 0),
        events: [
          AnimationEvent3D(name: 'bottom', time: 0.0),
          AnimationEvent3D(name: 'low', time: 0.25),
          AnimationEvent3D(name: 'high', time: 0.75),
          AnimationEvent3D(name: 'apex', time: 1.0),
        ],
      );

      final fired = <String>[];
      final state = AnimationState()
        ..onEvent = ((e) => fired.add(e.name))
        ..startAnimation(clip, mode: AnimationPlayMode.pingPong);

      // Forward 0.0 -> 0.6: `bottom`, `low`.
      state.update(0.6);
      expect(fired, ['bottom', 'low']);

      // Forward 0.6 -> 1.0 then bounce backward 1.0 -> 0.6 (`dt = 0.8`):
      // crosses `high` going up, `apex` ONCE at 1.0, and `high` going down!
      fired.clear();
      state.update(0.8);
      expect(fired, ['high', 'apex', 'high']);

      // Backward 0.6 -> 0.0 then bounce forward 0.0 -> 0.3 (`dt = 0.9`):
      // crosses `low` going down, `bottom` ONCE at 0.0, and `low` going up!
      fired.clear();
      state.update(0.9);
      expect(fired, ['low', 'bottom', 'low']);
    });

    test('ModelComponent.onAnimationEvent receives base & layer events', () {
      final model = Model(
        nodes: {
          0: ModelNode(
            name: 'Root',
            nodeIndex: 0,
            parentNodeIndex: null,
            transform: Matrix4.identity(),
            mesh: null,
            joints: const {},
          ),
          1: ModelNode(
            name: 'Arm',
            nodeIndex: 1,
            parentNodeIndex: 0,
            transform: Matrix4.identity(),
            mesh: null,
            joints: const {},
          ),
        },
        animations: [
          buildTranslationClip(
            'walk',
            duration: 1.0,
            start: Vector3.zero(),
            end: Vector3(1, 0, 0),
            events: [AnimationEvent3D(name: 'step', time: 0.4)],
          ),
          buildTranslationClip(
            'slash',
            nodeIndex: 1,
            duration: 1.0,
            start: Vector3.zero(),
            end: Vector3(0, 1, 0),
            events: [AnimationEvent3D(name: 'hit_frame', time: 0.25)],
          ),
        ],
      );

      final received = <String>[];
      final comp = ModelComponent(
        model: model,
        onAnimationEvent: (e) => received.add(e.name),
      )..playAnimationByName('walk');

      comp
          .addOverlayLayer(boneNames: const {'Arm'})
          .state
          .startAnimation(model.animations[1], mode: AnimationPlayMode.once);

      comp.update(0.5);
      expect(received, containsAll(<String>['step', 'hit_frame']));
    });
  });

  group('BlendSpace1D & BlendSpace2D locomotion blending', () {
    test('BlendSpace1D sorts samples and phase-locks Idle / Walk / Run', () {
      // Idle: x = 0, Walk (dur 1.2s): x = 0 -> 4, Run (dur 0.6s): x = 0 -> 12.
      final idle = buildTranslationClip(
        'Idle',
        duration: 1.0,
        start: Vector3.zero(),
        end: Vector3.zero(),
      );
      final walk = buildTranslationClip(
        'Walk',
        duration: 1.2,
        start: Vector3.zero(),
        end: Vector3(4, 0, 0),
      );
      final run = buildTranslationClip(
        'Run',
        duration: 0.6,
        start: Vector3.zero(),
        end: Vector3(12, 0, 0),
      );

      final space = BlendSpace1D(
        samples: [
          BlendSample1D(animation: run, position: 6.0),
          BlendSample1D(animation: idle, position: 0.0),
          BlendSample1D(animation: walk, position: 2.0),
        ],
      );
      expect(
        space.samples.map((s) => s.animation.name).toList(),
        ['Idle', 'Walk', 'Run'],
      );

      final model = Model(
        nodes: {
          0: ModelNode(
            name: 'Foot',
            nodeIndex: 0,
            parentNodeIndex: null,
            transform: Matrix4.identity(),
            mesh: null,
            joints: const {},
          ),
        },
        animations: [idle, walk, run],
      );

      final comp = ModelComponent(model: model)
        ..playBlendSpace1D(space, initialValue: 4.0);
      // At param = 4.0, bracket is Walk (2.0) <-> Run (6.0) with t = 0.5.
      // Effective duration = 0.5 * 1.2 + 0.5 * 0.6 = 0.9s.
      // Advancing by 0.45s reaches normalizedPhase = 0.5!
      comp.update(0.45);
      expect(comp.animationState.normalizedPhase, closeTo(0.5, 1e-5));

      // At phase = 0.5: Walk is at x = 2.0, Run is at x = 6.0 -> 50/50 = 4.0!
      expect(comp.nodeTransform(0)!.getTranslation().x, closeTo(4.0, 1e-4));

      // Sliding parameter to pure Run (6.0) keeps normalizedPhase = 0.5 ->
      // Run at 50% (t = 0.3s) = 6.0 without any phase discontinuity!
      comp.blendParameter1D = 6.0;
      expect(comp.nodeTransform(0)!.getTranslation().x, closeTo(6.0, 1e-4));
    });

    test('BlendSpace2D blends 4-way strafe poses and morph weights', () {
      final stride = VertexLayout.standard.strideInFloats;
      final verts = Float32List(3 * stride)
        ..[stride] = 1.0
        ..[2 * stride + 1] = 1.0;
      final morphSurf = Surface.fromBuffers(
        vertices: verts,
        indices: Uint16List.fromList(const [0, 1, 2]),
        morphTargets: [
          MorphTargetData(
            name: 'Lean',
            positionDeltas: Float32List.fromList(const [
              10.0,
              0.0,
              0.0,
              0.0,
              0.0,
              0.0,
              0.0,
              0.0,
              0.0,
            ]),
          ),
        ],
      );
      final mesh = Mesh()..addSurface(morphSurf);

      ModelAnimation dirClip(String name, Vector3 offset, double morphVal) {
        return buildTranslationClip(
          name,
          duration: 1.0,
          start: offset,
          end: offset,
          morphWeights: MorphWeightsChannel(
            interpolation: AnimationInterpolation.linear,
            times: const [0.0, 1.0],
            weights: [morphVal, morphVal],
            targetCount: 1,
          ),
        );
      }

      final north = dirClip('North', Vector3(0, 0, 4), 1.0);
      final south = dirClip('South', Vector3(0, 0, -4), 0.0);
      final east = dirClip('East', Vector3(4, 0, 0), 0.5);
      final west = dirClip('West', Vector3(-4, 0, 0), 0.0);

      final space2D = BlendSpace2D(
        samples: [
          BlendSample2D(animation: north, point: Vector2(0, 1)),
          BlendSample2D(animation: south, point: Vector2(0, -1)),
          BlendSample2D(animation: east, point: Vector2(1, 0)),
          BlendSample2D(animation: west, point: Vector2(-1, 0)),
        ],
      );

      final indices = Int32List(4);
      final weights = Float64List(4);
      final countNE = space2D.evaluateWeights(
        Vector2(0.5, 0.5),
        indices,
        weights,
      );
      expect(countNE, 2);
      expect(weights[0] + weights[1], closeTo(1.0, 1e-6));
      expect(weights[0], closeTo(0.5, 1e-5));
      expect(weights[1], closeTo(0.5, 1e-5));

      final model = Model(
        nodes: {
          0: ModelNode(
            name: 'Pelvis',
            nodeIndex: 0,
            parentNodeIndex: null,
            transform: Matrix4.identity(),
            mesh: mesh,
            joints: const {},
          ),
        },
        animations: [north, south, east, west],
      );

      final comp = ModelComponent(model: model)
        ..playBlendSpace2D(space2D, initialValue: Vector2(0.5, 0.5));
      comp.update(0.1);

      final pos = comp.nodeTransform(0)!.getTranslation();
      // 50% North (0, 0, 4) + 50% East (4, 0, 0) => (2, 0, 2)!
      expect(pos.x, closeTo(2.0, 1e-4));
      expect(pos.z, closeTo(2.0, 1e-4));
      // Morph weight: 0.5 * 1.0 + 0.5 * 0.5 = 0.75 => vertex x = 7.5!
      expect(morphSurf.vertexData[0], closeTo(7.5, 1e-4));
    });
  });

  group('RootMotionExtractor3D & OffscreenAnimationPolicy', () {
    test('extracts loop-safe root motion deltas and locks XZ in place', () {
      final hipsClip = ModelAnimation(
        name: 'run_rm',
        nodes: {
          0: NodeAnimation(
            channels: [
              AnimationController(
                animation: TranslationAnimationSpline.from(
                  interpolation: AnimationInterpolation.linear,
                  times: const [0.0, 1.0],
                  values: [Vector3(0, 1.0, 0), Vector3(0, 1.4, 2.0)],
                ),
              ),
              AnimationController(
                animation: RotationAnimationSpline.from(
                  interpolation: AnimationInterpolation.linear,
                  times: const [0.0, 1.0],
                  values: [
                    Quaternion.identity(),
                    Quaternion.axisAngle(Vector3(0, 1, 0), math.pi / 2),
                  ],
                ),
              ),
            ],
          ),
        },
      );

      final model = Model(
        nodes: {
          0: ModelNode(
            name: 'Hips',
            nodeIndex: 0,
            parentNodeIndex: null,
            transform: Matrix4.translationValues(0, 1.0, 0),
            mesh: null,
            joints: const {},
          ),
          1: ModelNode(
            name: 'Head',
            nodeIndex: 1,
            parentNodeIndex: 0,
            transform: Matrix4.translationValues(0, 0.5, 0),
            mesh: null,
            joints: const {},
          ),
        },
        animations: [hipsClip],
      );

      final rm = RootMotionExtractor3D(rootNodeName: 'Hips');
      final comp = ModelComponent(
        model: model,
        rootMotion: rm,
        rotation: Quaternion.axisAngle(Vector3(0, 1, 0), math.pi / 2),
      )..playAnimationByName('run_rm');

      // 0.0 -> 0.4: local Z advances +0.8; +90 deg around Y -> world +X!
      comp.update(0.4);
      expect(rm.deltaPositionLocal.z, closeTo(0.8, 1e-5));
      expect(rm.deltaPositionWorld.x, closeTo(0.8, 1e-5));
      expect(rm.deltaYawRad, closeTo(0.4 * (math.pi / 2), 1e-4));

      // 0.4 -> 0.9: local Z advances +1.0.
      comp.update(0.5);
      expect(rm.deltaPositionLocal.z, closeTo(1.0, 1e-5));

      // Loop wrap 0.9 -> 0.2 (`dt = 0.3` across 1.0 -> 0.0):
      // True displacement is (2.0 - 1.8) + (0.4 - 0.0) = +0.6, NOT -1.4!
      comp.update(0.3);
      expect(rm.deltaPositionLocal.z, closeTo(0.6, 1e-5));
      expect(rm.deltaYawRad, closeTo(0.3 * (math.pi / 2), 1e-4));

      // Visual pose keeps horizontal XZ locked at 0 while preserving Y bobbing!
      final hipsPos = comp.nodeTransform(0)!.getTranslation();
      final headPos = comp.nodeTransform(1)!.getTranslation();
      expect(hipsPos.x, closeTo(0.0, 1e-5));
      expect(hipsPos.z, closeTo(0.0, 1e-5));
      expect(hipsPos.y, closeTo(1.08, 1e-4));
      expect(headPos.z, closeTo(0.0, 1e-5));
    });

    test(
      'OffscreenAnimationPolicy.tickOnlyEvaluateWhenVisible & '
      'pauseWhenOffscreen avoid wasted pose evaluations',
      () {
        final events = <String>[];
        final clip = buildTranslationClip(
          'march',
          duration: 1.0,
          start: Vector3.zero(),
          end: Vector3(10, 0, 0),
          events: [AnimationEvent3D(name: 'halfway', time: 0.5)],
        );
        final model = Model(
          nodes: {
            0: ModelNode(
              name: 'Bone',
              nodeIndex: 0,
              parentNodeIndex: null,
              transform: Matrix4.identity(),
              mesh: CuboidMesh(size: Vector3.all(1)),
              joints: const {},
            ),
          },
          animations: [clip],
        );

        final lazyComp = ModelComponent(
          model: model,
          offscreenPolicy: OffscreenAnimationPolicy.tickOnlyEvaluateWhenVisible,
          onAnimationEvent: (e) => events.add(e.name),
        )..playAnimationByName('march', mode: AnimationPlayMode.once);

        for (var i = 0; i < 6; i++) {
          lazyComp.update(0.1);
        }
        // Clock advanced to 0.6 and event at 0.5 fired, with ZERO matrix pose
        // evaluations while culled offscreen!
        expect(lazyComp.animationState.clock, closeTo(0.6, 1e-6));
        expect(events, ['halfway']);
        expect(lazyComp.poseEvaluationsCount, 0);

        // Querying nodeTransform lazily evaluates the pose once.
        expect(
          lazyComp.nodeTransform(0)!.getTranslation().x,
          closeTo(6.0, 1e-4),
        );
        expect(lazyComp.poseEvaluationsCount, 1);
        expect(
          lazyComp.nodeTransform(0)!.getTranslation().x,
          closeTo(6.0, 1e-4),
        );
        expect(lazyComp.poseEvaluationsCount, 1);

        // `pauseWhenOffscreen` skips clock updates until drawn.
        final pausedComp = ModelComponent(
          model: model,
          offscreenPolicy: OffscreenAnimationPolicy.pauseWhenOffscreen,
        )..playAnimationByName('march');
        pausedComp.update(0.4);
        expect(pausedComp.animationState.clock, 0.0);
        expect(pausedComp.poseEvaluationsCount, 0);
      },
    );
  });

  group('SkinnedCrowdBatch3D baked pose banks & sub-node instancing', () {
    test('updates & draws 100+ crowd agents from pre-baked pose bank', () {
      final backend = FakeGpuBackend();
      final device = GraphicsDevice(backend: backend)..begin();
      final context = RenderContext3D(device)
        ..setCamera(
          Matrix4.identity(),
          Matrix4.identity(),
        );

      final skinnedMat = StylizedMaterial();
      final baseSkinned = StylizedMaterial.buildSurface(
        positions: const [0, 0, 0, 1, 0, 0, 0, 1, 0],
        normals: const [0, 0, 1, 0, 0, 1, 0, 0, 1],
        indices: const [0, 1, 2],
        joints: const [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        weights: const [1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0],
        material: skinnedMat,
      );
      final skinnedSurf = Surface.fromBuffers(
        vertices: baseSkinned.vertexData,
        indices: baseSkinned.indices,
        layout: baseSkinned.layout,
        material: skinnedMat,
        jointMap: const {0: 0},
      );
      final skinnedMesh = Mesh()..addSurface(skinnedSurf);
      final helmetMesh = CuboidMesh(
        size: Vector3.all(0.4),
        material: SpatialMaterial(),
      );

      final clip = buildTranslationClip(
        'jog',
        duration: 2.0,
        start: Vector3.zero(),
        end: Vector3(0, 0, 4),
      );

      final model = Model(
        nodes: {
          0: ModelNode(
            name: 'RootJoint',
            nodeIndex: 0,
            parentNodeIndex: null,
            transform: Matrix4.identity(),
            mesh: null,
            joints: const {},
          ),
          1: ModelNode(
            name: 'BodySkin',
            nodeIndex: 1,
            parentNodeIndex: null,
            transform: Matrix4.identity(),
            mesh: skinnedMesh,
            joints: {
              0: ModelJoint(
                nodeIndex: 0,
                inverseBindMatrix: Matrix4.identity(),
              ),
            },
          ),
          2: ModelNode(
            name: 'HelmetStatic',
            nodeIndex: 2,
            parentNodeIndex: 0,
            transform: Matrix4.translationValues(0, 1.6, 0),
            mesh: helmetMesh,
            joints: const {},
          ),
        },
        animations: [clip],
      );

      final crowd = SkinnedCrowdBatch3D(
        model: model,
        initialCapacity: 32,
      );
      expect(crowd.poseBanks.single.frameCount, 60);

      for (var i = 0; i < 100; i++) {
        crowd.addAgent(
          position: Vector3((i % 10) * 2.0, 0, (i ~/ 10) * 2.0),
          initialClock: (i % 60) / 30.0,
        );
      }
      expect(crowd.length, 100);
      expect(crowd.computeLocalAabb(), isNotNull);

      crowd.update(0.25);
      // Agents sharing a quantized frame index share the exact same pre-baked
      // joint palette reference (`0` per-frame Matrix4 allocations).
      final a0Frame = crowd.agentFrameIndex(0);
      final a60Frame = crowd.agentFrameIndex(60);
      expect(a0Frame, a60Frame);
      expect(
        identical(
          crowd.agentPose(0).first.jointTransforms,
          crowd.agentPose(60).first.jointTransforms,
        ),
        isTrue,
      );

      crowd.draw(context);
      expect(crowd.lastSkinnedNodeDraws, 100);
      // All 100 unskinned helmets coalesce into 1 `drawInstances` submission!
      expect(crowd.lastInstancedSubNodeDraws, 1);

      final rayHit = crowd.raycast(
        Ray.originDirection(Vector3(0, 1.6, -5), Vector3(0, 0, 1)),
      );
      expect(rayHit, isNotNull);

      device.end();
    });
  });
}
