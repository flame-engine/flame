import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/model.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_fakes/fake_gpu_backend.dart';

Model _buildChainModel(int jointCount) {
  final nodes = <int, ModelNode>{};
  final modelJoints = <int, ModelJoint>{};
  final surfaceJointMap = <int, int>{};
  for (var i = 0; i < jointCount; i++) {
    final local = i == 0
        ? Matrix4.identity()
        : Matrix4.translationValues(0, 1.0, 0);
    nodes[i] = ModelNode(
      name: 'Bone_$i',
      nodeIndex: i,
      parentNodeIndex: i == 0 ? null : i - 1,
      transform: local,
      mesh: null,
      joints: const {},
    );
    modelJoints[i] = ModelJoint(
      nodeIndex: i,
      inverseBindMatrix: Matrix4.translationValues(0, -i.toDouble(), 0),
    );
    surfaceJointMap[i] = i;
  }

  final mat = StylizedMaterial();
  final baseSurf = StylizedMaterial.buildSurface(
    positions: const [0, 0, 0, 1, 0, 0, 0, 1, 0],
    normals: const [0, 0, 1, 0, 0, 1, 0, 0, 1],
    indices: const [0, 1, 2],
    joints: [
      0,
      (jointCount - 1).toDouble(),
      0,
      0,
      0,
      (jointCount - 1).toDouble(),
      0,
      0,
      0,
      (jointCount - 1).toDouble(),
      0,
      0,
    ],
    weights: const [
      0.25, 0.75, 0, 0, //
      0.25, 0.75, 0, 0, //
      0.25, 0.75, 0, 0, //
    ],
    material: mat,
  );
  final surface = Surface.fromBuffers(
    vertices: baseSurf.vertexData,
    indices: baseSurf.indices,
    layout: baseSurf.layout,
    material: mat,
    jointMap: surfaceJointMap,
  );
  final skinnedMesh = Mesh()..addSurface(surface);
  nodes[jointCount] = ModelNode(
    name: 'MeshNode',
    nodeIndex: jointCount,
    parentNodeIndex: null,
    transform: Matrix4.identity(),
    mesh: skinnedMesh,
    joints: modelJoints,
  );
  return Model(nodes: nodes, animations: const []);
}

void main() {
  group('64-bone skinning, morph targets, CubicSpline, layers & IK', () {
    test('StylizedMaterial & ModelPoseWorkspace support up to 64 joints', () {
      expect(StylizedMaterial.maxJoints, 64);
      final model = _buildChainModel(40);
      final workspace = ModelPoseWorkspace.forModel(model);
      model.evaluateInto(AnimationState(), workspace);

      final surfaceJoints = workspace.nodesByIndex[40]!.jointTransforms[0]!;
      expect(surfaceJoints, hasLength(40));
      for (var j = 0; j < 40; j++) {
        expect(surfaceJoints[j].getTranslation().length, lessThan(1e-5));
      }
    });

    test(
      'Surface.applyMorphWeights blends position & normal deltas and '
      'Surface.updateVertices + Resource.dispose manage GPU buffers',
      () {
        final backend = FakeGpuBackend();
        final device = GraphicsDevice(backend: backend)..begin();

        final stride = VertexLayout.standard.strideInFloats;
        final baseVerts = Float32List(3 * stride);
        baseVerts[10] = 1.0;
        baseVerts[stride] = 1.0;
        baseVerts[stride + 10] = 1.0;
        baseVerts[2 * stride + 1] = 1.0;
        baseVerts[2 * stride + 10] = 1.0;

        final targetA = MorphTargetData(
          name: 'StretchX',
          positionDeltas: Float32List.fromList([
            2.0, 0.0, 0.0, //
            0.0, 0.0, 0.0, //
            0.0, 0.0, 0.0, //
          ]),
          normalDeltas: Float32List.fromList([
            1.0, 0.0, 0.0, //
            0.0, 0.0, 0.0, //
            0.0, 0.0, 0.0, //
          ]),
        );
        final targetB = MorphTargetData(
          name: 'LiftY',
          positionDeltas: Float32List.fromList([
            0.0, 4.0, 0.0, //
            0.0, 0.0, 0.0, //
            0.0, 0.0, 0.0, //
          ]),
        );

        final surface = Surface.fromBuffers(
          vertices: baseVerts,
          indices: Uint16List.fromList(const [0, 1, 2]),
          morphTargets: [targetA, targetB],
        );

        expect(surface.hasResource, isFalse);
        final _ = surface.resource;
        expect(surface.hasResource, isTrue);

        surface.applyMorphWeights([0.5, 0.25]);
        final morphed = surface.vertexData;
        expect(morphed[0], closeTo(1.0, 1e-5));
        expect(morphed[1], closeTo(1.0, 1e-5));
        expect(morphed[9], closeTo(0.5 / math.sqrt(1.25), 1e-4));
        expect(morphed[10], closeTo(1.0 / math.sqrt(1.25), 1e-4));

        surface.applyMorphWeights(const [0.0, 0.0]);
        expect(surface.vertexData[0], closeTo(0.0, 1e-6));

        final customVerts = Float32List.fromList(baseVerts)..[0] = 7.5;
        surface.updateVertices(customVerts);
        expect(surface.vertexData[0], closeTo(7.5, 1e-6));

        surface.dispose();
        expect(surface.hasResource, isFalse);
        device.end();
      },
    );

    test(
      'AnimationInterpolation.cubicSpline supports Hermite triplets and '
      'smoothstep fallback',
      () {
        final hermite = TranslationAnimationSpline.from(
          interpolation: AnimationInterpolation.cubicSpline,
          times: const [0.0, 2.0],
          values: [
            Vector3.zero(),
            Vector3.zero(),
            Vector3(4, 0, 0),
            Vector3.zero(),
            Vector3(10, 0, 0),
            Vector3.zero(),
          ],
        );
        final hermiteCtrl = AnimationController(animation: hermite);
        final t = Vector3.zero();
        final r = Quaternion.identity();
        final s = Vector3.all(1);
        hermiteCtrl.sampleTrsInto(0.0, t, r, s);
        expect(t.x, closeTo(0.0, 1e-5));
        hermiteCtrl.sampleTrsInto(2.0, t, r, s);
        expect(t.x, closeTo(10.0, 1e-5));
        hermiteCtrl.sampleTrsInto(1.0, t, r, s);
        expect(t.x, closeTo(6.0, 1e-5));

        final smoothCtrl = AnimationController(
          animation: ScaleAnimationSpline.from(
            interpolation: AnimationInterpolation.cubicSpline,
            times: const [0.0, 1.0],
            values: [Vector3.all(1), Vector3.all(3)],
          ),
        );
        smoothCtrl.sampleTrsInto(0.5, t, r, s);
        expect(s.x, closeTo(2.0, 1e-5));
      },
    );

    test(
      'AnimationLayer3D masks upper-body bones over base clip and animates '
      'MorphWeightsChannel',
      () {
        final stride = VertexLayout.standard.strideInFloats;
        final verts = Float32List(3 * stride)
          ..[stride] = 1.0
          ..[2 * stride + 1] = 1.0;
        final morphSurf = Surface.fromBuffers(
          vertices: verts,
          indices: Uint16List.fromList(const [0, 1, 2]),
          morphTargets: [
            MorphTargetData(
              name: 'Pulse',
              positionDeltas: Float32List.fromList([
                5.0, 0.0, 0.0, //
                0.0, 0.0, 0.0, //
                0.0, 0.0, 0.0, //
              ]),
            ),
          ],
        );
        final mesh = Mesh()..addSurface(morphSurf);

        final nodes = {
          0: ModelNode(
            name: 'Hips',
            nodeIndex: 0,
            parentNodeIndex: null,
            transform: Matrix4.identity(),
            mesh: null,
            joints: const {},
          ),
          1: ModelNode(
            name: 'Torso',
            nodeIndex: 1,
            parentNodeIndex: 0,
            transform: Matrix4.translationValues(0, 1, 0),
            mesh: mesh,
            joints: const {},
          ),
        };

        final walkBase = ModelAnimation(
          name: 'walk',
          nodes: {
            0: NodeAnimation(
              channels: [
                AnimationController(
                  animation: TranslationAnimationSpline.from(
                    interpolation: AnimationInterpolation.linear,
                    times: const [0.0, 1.0],
                    values: [Vector3(2, 0, 0), Vector3(2, 0, 0)],
                  ),
                ),
              ],
            ),
            1: NodeAnimation(
              channels: [
                AnimationController(
                  animation: TranslationAnimationSpline.from(
                    interpolation: AnimationInterpolation.linear,
                    times: const [0.0, 1.0],
                    values: [Vector3(0, 1, 0), Vector3(0, 1, 0)],
                  ),
                ),
              ],
            ),
          },
        );

        final upperWave = ModelAnimation(
          name: 'wave',
          nodes: {
            0: NodeAnimation(
              channels: [
                AnimationController(
                  animation: TranslationAnimationSpline.from(
                    interpolation: AnimationInterpolation.linear,
                    times: const [0.0, 1.0],
                    values: [Vector3(99, 0, 0), Vector3(99, 0, 0)],
                  ),
                ),
              ],
            ),
            1: NodeAnimation(
              channels: [
                AnimationController(
                  animation: TranslationAnimationSpline.from(
                    interpolation: AnimationInterpolation.linear,
                    times: const [0.0, 1.0],
                    values: [Vector3(0, 3, 0), Vector3(0, 3, 0)],
                  ),
                ),
              ],
              morphWeights: MorphWeightsChannel(
                targetCount: 1,
                interpolation: AnimationInterpolation.linear,
                times: const [0.0, 1.0],
                weights: Float32List.fromList(const [0.0, 0.8]),
              ),
            ),
          },
        );

        final model = Model(nodes: nodes, animations: [walkBase, upperWave]);
        final comp = ModelComponent(model: model)..playAnimationByName('walk');
        comp
            .addOverlayLayer(boneNames: const {'Torso'}, weight: 0.5)
            .state
            .startAnimation(upperWave);

        comp.update(0.5);
        final workspace = comp.evaluatePose();

        // Node 0 (`Hips`) ignores `upperWave` (`99`) and stays at `walk` (`2`).
        final hipsPos = workspace.nodesByIndex[0]!.combinedTransform
            .getTranslation();
        expect(hipsPos.x, closeTo(2.0, 1e-5));
        // Node 1 (`Torso`) blends 50% between local y=1 and y=3 -> y=2.
        final torsoPos = workspace.nodesByIndex[1]!.combinedTransform
            .getTranslation();
        expect(torsoPos.y, closeTo(2.0, 1e-5));
        // Morph weight at t=0.5 is 0.4 * 0.5 = 0.2 -> x = 0.2 * 5 = 1.0!
        expect(morphSurf.vertexData[0], closeTo(1.0, 1e-4));
      },
    );

    test(
      'TwoBoneIkConstraint3D, LookAtConstraint3D & SpringBone3D deform '
      'joint poses accurately',
      () {
        final nodes = {
          0: ModelNode(
            name: 'Shoulder',
            nodeIndex: 0,
            parentNodeIndex: null,
            transform: Matrix4.identity(),
            mesh: null,
            joints: const {},
          ),
          1: ModelNode(
            name: 'Elbow',
            nodeIndex: 1,
            parentNodeIndex: 0,
            transform: Matrix4.translationValues(0, 1, 0),
            mesh: null,
            joints: const {},
          ),
          2: ModelNode(
            name: 'Hand',
            nodeIndex: 2,
            parentNodeIndex: 1,
            transform: Matrix4.translationValues(0, 1, 0),
            mesh: null,
            joints: const {},
          ),
          3: ModelNode(
            name: 'Head',
            nodeIndex: 3,
            parentNodeIndex: null,
            transform: Matrix4.translationValues(0, 3, 0),
            mesh: null,
            joints: const {},
          ),
          4: ModelNode(
            name: 'TailTip',
            nodeIndex: 4,
            parentNodeIndex: 3,
            transform: Matrix4.translationValues(0, 1, 0),
            mesh: null,
            joints: const {},
          ),
        };
        final model = Model(nodes: nodes, animations: const []);
        final comp = ModelComponent(model: model);

        final targetWorld = Vector3(1.2, 1.0, 0.0);
        final ik = TwoBoneIkConstraint3D(
          rootNodeName: 'Shoulder',
          midNodeName: 'Elbow',
          tipNodeName: 'Hand',
          targetWorld: targetWorld,
          poleWorld: Vector3(0, 2, 1),
        );
        final lookAt = LookAtConstraint3D(
          nodeName: 'Head',
          targetWorld: Vector3(0, 3, 5),
          forwardAxis: Vector3(0, 0, 1),
          maxAngle: math.pi,
        );
        final spring = SpringBone3D(
          nodeName: 'TailTip',
          stiffness: 14.0,
          damping: 6.0,
        );

        comp.boneModifiers.addAll([ik, lookAt, spring]);
        comp.update(0.016);
        var workspace = comp.evaluatePose();

        // 1. Two-bone IK places `Hand` (node 2) right onto `targetWorld`!
        final handPos = workspace.nodesByIndex[2]!.combinedTransform
            .getTranslation();
        expect(handPos.distanceTo(targetWorld), lessThan(1e-3));

        // 2. LookAt rotates `Head` when target moves to +X `(5, 3, 0)`.
        lookAt.targetWorld.setValues(5, 3, 0);
        comp.update(0.016);
        workspace = comp.evaluatePose();
        final headRot = Matrix3.zero();
        workspace.nodesByIndex[3]!.combinedTransform.copyRotation(headRot);
        final headForward = headRot.transformed(Vector3(0, 0, 1))..normalize();
        expect(headForward.x, closeTo(1.0, 1e-4));

        // 3. SpringBone rotates `TailTip` so its tip (`localTipOffset`) lags
        // behind sudden +X lunge of the character!
        comp.position.setValues(3.0, 0.0, 0.0);
        comp.update(0.016);
        workspace = comp.evaluatePose();
        final headMoved = comp.worldTransformMatrix.transformed3(
          workspace.nodesByIndex[3]!.combinedTransform.getTranslation(),
        );
        final tipModel = workspace.nodesByIndex[4]!.combinedTransform
            .transformed3(spring.localTipOffset);
        final tipDragged = comp.worldTransformMatrix.transformed3(tipModel);
        expect(tipDragged.x, lessThan(headMoved.x - 0.05));
        expect(spring.currentTipWorld.x, lessThan(headMoved.x - 0.05));
      },
    );
  });
}
