import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/model.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

ModelAnimation _translateClip(String name, double endX, {double duration = 1}) {
  return ModelAnimation(
    name: name,
    nodes: {
      0: NodeAnimation(
        channels: [
          AnimationController(
            animation: TranslationAnimationSpline.from(
              interpolation: AnimationInterpolation.linear,
              times: [0.0, duration],
              values: [Vector3.zero(), Vector3(endX, 0, 0)],
            ),
          ),
        ],
      ),
    },
  );
}

void main() {
  group('AnimationState modes, crossfades & BoneSocket3D', () {
    test(
      'AnimationPlayMode.once clamps at end and invokes onComplete once',
      () {
        var completions = 0;
        final clip = _translateClip('slide', 4.0);
        final state = AnimationState()
          ..startAnimation(
            clip,
            mode: AnimationPlayMode.once,
            onComplete: () => completions++,
          );

        expect(state.update(0.4), isTrue);
        expect(state.isCompleted, isFalse);
        expect(completions, 0);

        expect(state.update(0.8), isTrue);
        expect(state.clock, closeTo(1.0, 1e-6));
        expect(state.isCompleted, isTrue);
        expect(completions, 1);

        expect(state.update(0.5), isFalse);
        expect(completions, 1);
      },
    );

    test('AnimationPlayMode.pingPong bounces cleanly across clip bounds', () {
      final clip = _translateClip('bounce', 2.0);
      final state = AnimationState()
        ..startAnimation(clip, mode: AnimationPlayMode.pingPong);

      state.update(0.75);
      expect(state.clock, closeTo(0.75, 1e-6));
      state.update(0.5);
      // 0.75 + 0.5 = 1.25 -> reflects from 1.0 back to 0.75!
      expect(state.clock, closeTo(0.75, 1e-6));
    });

    test(
      'crossFadeTo blends TRS and preserves rest scale on rotation clips',
      () {
        final node = ModelNode(
          name: 'Arm',
          nodeIndex: 0,
          parentNodeIndex: null,
          transform: Matrix4.diagonal3Values(2, 3, 4),
          mesh: CuboidMesh(size: Vector3.all(1)),
          joints: {},
        );
        final rotClipA = ModelAnimation(
          name: 'poseA',
          nodes: {
            0: NodeAnimation(
              channels: [
                AnimationController(
                  animation: RotationAnimationSpline.from(
                    interpolation: AnimationInterpolation.linear,
                    times: [0, 1],
                    values: [Quaternion.identity(), Quaternion.identity()],
                  ),
                ),
              ],
            ),
          },
        );
        final rotClipB = ModelAnimation(
          name: 'poseB',
          nodes: {
            0: NodeAnimation(
              channels: [
                AnimationController(
                  animation: RotationAnimationSpline.from(
                    interpolation: AnimationInterpolation.linear,
                    times: [0, 1],
                    values: [
                      Quaternion.axisAngle(Vector3(0, 0, 1), math.pi / 2),
                      Quaternion.axisAngle(Vector3(0, 0, 1), math.pi / 2),
                    ],
                  ),
                ),
                AnimationController(
                  animation: TranslationAnimationSpline.from(
                    interpolation: AnimationInterpolation.linear,
                    times: [0, 1],
                    values: [Vector3(10, 0, 0), Vector3(10, 0, 0)],
                  ),
                ),
              ],
            ),
          },
        );

        final model = Model(nodes: {0: node}, animations: [rotClipA, rotClipB]);
        final workspace = ModelPoseWorkspace.forModel(model);
        final state = AnimationState()
          ..startAnimation(rotClipA)
          ..crossFadeTo(rotClipB, duration: 1.0);

        state.update(0.5);
        expect(state.isCrossFading, isTrue);
        expect(state.crossFadeProgress, closeTo(0.5, 1e-6));

        model.evaluateInto(state, workspace);
        final m = workspace.nodesByIndex[0]!.combinedTransform;
        final t = Vector3.zero();
        final r = Quaternion.identity();
        final s = Vector3.zero();
        m.decompose(t, r, s);

        expect(t.x, closeTo(5.0, 1e-4));
        // Rest scale `(2, 3, 4)` stays intact even though only rotation &
        // translation were animated!
        expect(s.x, closeTo(2.0, 1e-4));
        expect(s.y, closeTo(3.0, 1e-4));
        expect(s.z, closeTo(4.0, 1e-4));
        // Halfway rotation between 0 and 90 deg around Z is 45 deg.
        final halfAngle = Quaternion.axisAngle(Vector3(0, 0, 1), math.pi / 4);
        expect((r.z - halfAngle.z).abs(), lessThan(1e-4));
        expect((r.w - halfAngle.w).abs(), lessThan(1e-4));

        // Model.animatedAabb encompasses the translated pose (`x = 10`).
        expect(model.animatedAabb.max.x, greaterThanOrEqualTo(10.9));
      },
    );

    test('BoneSocket3D follows named bone transforms', () async {
      final handNode = ModelNode(
        name: 'Hand.R',
        nodeIndex: 0,
        parentNodeIndex: null,
        transform: Matrix4.identity(),
        mesh: CuboidMesh(size: Vector3.all(0.2)),
        joints: {},
      );
      final clip = _translateClip('reach', 6.0);
      final model = Model(nodes: {0: handNode}, animations: [clip]);

      final sword = MeshComponent(mesh: CuboidMesh(size: Vector3.all(0.1)));
      final socket = BoneSocket3D.byName('Hand.R', children: [sword]);
      final character = ModelComponent(
        model: model,
        position: Vector3(1, 2, 3),
        children: [socket],
      )..playAnimationByName('reach', mode: AnimationPlayMode.once);

      final world = World3D(children: [character]);
      final game = FlameGame(world: world);
      await game.onLoad();
      game.update(0);
      game.update(0.5);

      // Character at `(1, 2, 3)` + bone at `(3, 0, 0)` => sword at `(4, 2, 3)`.
      expect(sword.worldTransformMatrix.storage[12], closeTo(4.0, 1e-4));
      expect(sword.worldTransformMatrix.storage[13], closeTo(2.0, 1e-4));
      expect(sword.worldTransformMatrix.storage[14], closeTo(3.0, 1e-4));
    });
  });
}
