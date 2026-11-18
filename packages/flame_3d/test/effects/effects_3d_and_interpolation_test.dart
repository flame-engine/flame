import 'dart:math' as math;
import 'dart:ui' show Color;

import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/effects.dart';
import 'package:flame_3d/model.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/animation.dart' show Curves;
import 'package:flutter_test/flutter_test.dart';

class _InterpolatedNode({
  super.position,
  super.rotation,
  super.scale,
}) extends Component3D with FixedTransformInterpolation3D;

void main() {
  group('3D Transform & Material Effects', () {
    testWithFlameGame(
      'MoveToEffect3D and MoveByEffect3D translate cleanly',
      (game) async {
        final node = _InterpolatedNode(position: Vector3(1, 2, 3));
        final world = World3D(children: [node]);
        await game.ensureAdd(world);

        var completed = false;
        final moveTo = MoveToEffect3D(
          Vector3(5, -2, 7),
          LinearEffectController(1.0),
          onComplete: () => completed = true,
        );
        await node.ensureAdd(moveTo);

        game.update(0.5);
        expect(node.position, closeToVector3(Vector3(3, 0, 5), 1e-5));
        expect(completed, isFalse);

        game.update(0.5);
        expect(node.position, closeToVector3(Vector3(5, -2, 7), 1e-5));
        expect(completed, isTrue);

        final moveBy = MoveByEffect3D(
          Vector3(-2, 4, -3),
          LinearEffectController(1.0),
        );
        await node.ensureAdd(moveBy);

        game.update(0.25);
        expect(node.position, closeToVector3(Vector3(4.5, -1, 6.25), 1e-5));
        game.update(0.75);
        expect(node.position, closeToVector3(Vector3(3, 2, 4), 1e-5));
      },
    );

    testWithFlameGame(
      'ArcMoveEffect3D follows parabolic jump height and lands on target',
      (game) async {
        final node = _InterpolatedNode(position: Vector3.zero());
        final world = World3D(children: [node]);
        await game.ensureAdd(world);

        await node.ensureAdd(
          ArcMoveEffect3D(
            Vector3(10, 0, 0),
            LinearEffectController(2.0),
            arcHeight: 3.0,
          ),
        );

        game.update(1.0);
        expect(node.position, closeToVector3(Vector3(5, 3, 0), 1e-5));

        game.update(0.5);
        expect(node.position, closeToVector3(Vector3(7.5, 2.25, 0), 1e-5));

        game.update(0.5);
        expect(node.position, closeToVector3(Vector3(10, 0, 0), 1e-5));
      },
    );

    testWithFlameGame(
      'SplinePathEffect3D traverses spline and orients to tangent',
      (game) async {
        final spline = CatmullRomSpline3D([
          Vector3(0, 0, 0),
          Vector3(4, 0, -4),
          Vector3(8, 0, 0),
        ]);
        final node = _InterpolatedNode();
        final world = World3D(children: [node]);
        await game.ensureAdd(world);

        await node.ensureAdd(
          SplinePathEffect3D(
            spline,
            LinearEffectController(1.0),
            orientToTangent: true,
          ),
        );

        game.update(0.5);
        expect(
          node.position,
          closeToVector3(spline.samplePoint(0.5), 1e-5),
        );
        final expectedTangent = spline.sampleTangent(0.5);
        final forward = Vector3(0, 0, -1)..applyQuaternion(node.rotation);
        expect(forward, closeToVector3(expectedTangent, 1e-4));

        game.update(0.5);
        expect(node.position, closeToVector3(Vector3(8, 0, 0), 1e-5));
      },
    );

    testWithFlameGame(
      'RotateToEffect3D takes shortest hemisphere Slerp path',
      (game) async {
        final node = _InterpolatedNode(rotation: Quaternion.identity());
        final world = World3D(children: [node]);
        await game.ensureAdd(world);

        final q90 = Quaternion.axisAngle(Vector3(0, 1, 0), math.pi / 2);
        final negatedTarget = Quaternion(-q90.x, -q90.y, -q90.z, -q90.w);

        await node.ensureAdd(
          RotateToEffect3D(negatedTarget, LinearEffectController(1.0)),
        );

        game.update(0.5);
        final rotatedForward = Vector3(0, 0, -1)
          ..applyQuaternion(node.rotation);
        expect(
          rotatedForward,
          closeToVector3(
            Vector3(-math.sqrt1_2, 0, -math.sqrt1_2),
            1e-4,
          ),
        );

        game.update(0.5);
        final finalForward = Vector3(0, 0, -1)..applyQuaternion(node.rotation);
        expect(finalForward, closeToVector3(Vector3(-1, 0, 0), 1e-4));
      },
    );

    testWithFlameGame(
      'RotateAroundEffect3D spins in place and around a 3D pivot',
      (game) async {
        final spinner = _InterpolatedNode();
        final orbiter = _InterpolatedNode(position: Vector3(2, 0, 0));
        final world = World3D(children: [spinner, orbiter]);
        await game.ensureAdd(world);

        await spinner.ensureAdd(
          RotateAroundEffect3D(
            axis: Vector3(0, 1, 0),
            radians: math.pi,
            controller: LinearEffectController(1.0),
          ),
        );
        await orbiter.ensureAdd(
          RotateAroundEffect3D(
            axis: Vector3(0, 1, 0),
            radians: math.pi / 2,
            pivot: Vector3.zero(),
            controller: LinearEffectController(1.0),
          ),
        );

        game.update(1.0);
        final spinForward = Vector3(0, 0, -1)
          ..applyQuaternion(spinner.rotation);
        expect(spinForward, closeToVector3(Vector3(0, 0, 1), 1e-4));
        expect(orbiter.position, closeToVector3(Vector3(0, 0, -2), 1e-4));
      },
    );

    testWithFlameGame(
      'ScaleToEffect3D and SquashStretchEffect3D preserve volume',
      (game) async {
        final node = _InterpolatedNode(scale: Vector3.all(2));
        final world = World3D(children: [node]);
        await game.ensureAdd(world);

        await node.ensureAdd(
          SquashStretchEffect3D(
            intensity: 0.44,
            controller: LinearEffectController(1.0),
          ),
        );

        game.update(0.5);
        expect(node.scale.y, closeTo(2.0 * 1.44, 1e-5));
        expect(node.scale.x, closeTo(2.0 / 1.2, 1e-5));
        expect(node.scale.z, closeTo(2.0 / 1.2, 1e-5));
        expect(
          node.scale.x * node.scale.y * node.scale.z,
          closeTo(8.0, 1e-4),
        );

        game.update(0.5);
        expect(node.scale, closeToVector3(Vector3.all(2), 1e-6));

        await node.ensureAdd(
          ScaleToEffect3D(Vector3(1, 3, 0.5), LinearEffectController(1.0)),
        );
        game.update(1.0);
        expect(node.scale, closeToVector3(Vector3(1, 3, 0.5), 1e-5));
      },
    );

    testWithFlameGame(
      'ColorTintEffect3D and InstanceDataEffect3D mark World3D dirty',
      (game) async {
        final meshComp = MeshComponent(
          mesh: CuboidMesh(size: Vector3.all(1)),
          color: const Color.from(alpha: 1.0, red: 0.0, green: 0.0, blue: 1.0),
          instanceData: Vector4(0, 0, 0, 1),
        );
        final model = Model(
          nodes: {
            0: ModelNode.simple(
              nodeIndex: 0,
              mesh: CuboidMesh(size: Vector3.all(1)),
            ),
          },
          animations: const [],
        );
        final modelComp = ModelComponent(
          model: model,
          instanceData: Vector4(1, 2, 3, 4),
        );
        final world = World3D(children: [meshComp, modelComp]);
        await game.ensureAdd(world);

        await meshComp.ensureAdd(
          ColorTintEffect3D(
            const Color.from(alpha: 0.5, red: 1.0, green: 0.4, blue: 0.0),
            LinearEffectController(1.0),
          ),
        );
        await meshComp.ensureAdd(
          InstanceDataEffect3D(
            Vector4(4, 2, -2, 0),
            LinearEffectController(1.0),
          ),
        );
        await modelComp.ensureAdd(
          InstanceDataEffect3D(
            Vector4(5, 6, 7, 8),
            LinearEffectController(1.0),
          ),
        );

        final versionBefore = world.sceneVersion;
        game.update(0.5);
        expect(world.sceneVersion, greaterThan(versionBefore));

        expect(meshComp.color.r, closeTo(0.5, 0.01));
        expect(meshComp.color.g, closeTo(0.2, 0.01));
        expect(meshComp.color.b, closeTo(0.5, 0.01));
        expect(meshComp.color.a, closeTo(0.75, 0.01));
        expect(
          meshComp.instanceData,
          closeToVector4(Vector4(2, 1, -1, 0.5), 1e-5),
        );
        expect(
          modelComp.instanceData,
          closeToVector4(Vector4(3, 4, 5, 6), 1e-5),
        );

        game.update(0.5);
        expect(
          meshComp.instanceData,
          closeToVector4(Vector4(4, 2, -2, 0), 1e-5),
        );
        expect(
          modelComp.instanceData,
          closeToVector4(Vector4(5, 6, 7, 8), 1e-5),
        );
      },
    );

    testWithFlameGame(
      'SequenceEffect and SpringEffectController compose on Component3D',
      (game) async {
        final node = _InterpolatedNode();
        final world = World3D(children: [node]);
        await game.ensureAdd(world);

        var sequenceDone = false;
        final sequence = SequenceEffect(
          [
            MoveToEffect3D(Vector3(0, 4, 0), LinearEffectController(0.5)),
            ScaleToEffect3D(Vector3.all(2), LinearEffectController(0.5)),
          ],
          onComplete: () => sequenceDone = true,
        );
        await node.ensureAdd(sequence);

        game.update(0.5);
        expect(node.position, closeToVector3(Vector3(0, 4, 0), 1e-5));
        expect(node.scale, closeToVector3(Vector3.all(1), 1e-5));

        game.update(0.55);
        expect(node.scale, closeToVector3(Vector3.all(2), 1e-5));
        expect(sequenceDone, isTrue);

        final springController = CurvedEffectController(
          0.6,
          Curves.elasticOut,
        );
        await node.ensureAdd(
          MoveToEffect3D(Vector3(0, 10, 0), springController),
        );

        var peakY = node.position.y;
        const step = 1 / 120;
        for (var i = 0; i < 360 && !springController.completed; i++) {
          game.update(step);
          if (node.position.y > peakY) {
            peakY = node.position.y;
          }
        }
        expect(peakY, greaterThan(10.2));
        expect(node.position, closeToVector3(Vector3(0, 10, 0), 0.02));
      },
    );
  });

  group('FixedTransformInterpolation3D', () {
    test('interpolates position, scale, and shortest-arc Quaternion Slerp', () {
      final qStart = Quaternion.identity();
      final qEndRaw = Quaternion.axisAngle(Vector3(0, 1, 0), math.pi / 2);
      final qEndNegated = Quaternion(
        -qEndRaw.x,
        -qEndRaw.y,
        -qEndRaw.z,
        -qEndRaw.w,
      );

      final body = _InterpolatedNode(
        position: Vector3.zero(),
        rotation: qStart,
        scale: Vector3.all(1),
      )..captureFixedState();
      body.position.setValues(10, -4, 6);
      body.rotation.setFrom(qEndNegated);
      body.scale.setValues(3, 1, 2);
      body
        ..commitFixedState()
        ..applyInterpolationAlpha(0.25);

      expect(body.isInterpolated, isTrue);
      expect(body.position, closeToVector3(Vector3(2.5, -1, 1.5), 1e-5));
      expect(body.scale, closeToVector3(Vector3(1.5, 1, 1.25), 1e-5));

      body.applyInterpolationAlpha(0.5);
      expect(body.position, closeToVector3(Vector3(5, -2, 3), 1e-5));
      final halfForward = Vector3(0, 0, -1)..applyQuaternion(body.rotation);
      expect(
        halfForward,
        closeToVector3(Vector3(-math.sqrt1_2, 0, -math.sqrt1_2), 1e-4),
      );

      body.restoreSimulatedState();
      expect(body.isInterpolated, isFalse);
      expect(body.position, closeToVector3(Vector3(10, -4, 6), 1e-5));
      expect(body.scale, closeToVector3(Vector3(3, 1, 2), 1e-5));
      final endForward = Vector3(0, 0, -1)..applyQuaternion(body.rotation);
      expect(endForward, closeToVector3(Vector3(-1, 0, 0), 1e-4));
    });

    test('teleportFixedState snaps both states so teleports do not streak', () {
      final body = _InterpolatedNode(position: Vector3.zero())
        ..captureFixedState();
      body.position.setValues(200, 50, -100);
      body
        ..teleportFixedState()
        ..applyInterpolationAlpha(0.35);

      expect(body.position, closeToVector3(Vector3(200, 50, -100), 1e-5));
      body.restoreSimulatedState();
      expect(body.position, closeToVector3(Vector3(200, 50, -100), 1e-5));
    });
  });
}
