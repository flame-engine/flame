import 'dart:math' as math;

import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrbitCameraController3D', () {
    test(
      'orbits, clamps pitch & distance, smooths exponentially, and pans',
      () {
        final camera = CameraComponent3D(
          viewport: FixedSizeViewport(800, 600),
        );
        final rig = OrbitCameraController3D(
          camera: camera,
          target: Vector3(1, 2, 3),
          pitch: 0,
          minPitch: -1.0,
          maxPitch: 1.0,
          distance: 10,
          minDistance: 2,
          maxDistance: 30,
          damping: 10,
        );

        expect(camera.position, closeToVector3(Vector3(1, 2, 13), 1e-5));
        expect(camera.target, closeToVector3(Vector3(1, 2, 3), 1e-5));

        rig
          ..orbitBy(math.pi / 2, 5.0)
          ..zoomByFactor(2.0);
        expect(rig.pitch, closeTo(1.0, 1e-6));
        expect(rig.distance, closeTo(5.0, 1e-6));

        rig.update(0.05);
        expect(camera.position.distanceTo(camera.target), lessThan(10.0));
        expect(camera.position.distanceTo(camera.target), greaterThan(5.1));

        for (var i = 0; i < 60; i++) {
          rig.update(1 / 30);
        }
        expect(camera.position.distanceTo(camera.target), closeTo(5.0, 1e-3));

        final targetBefore = rig.target.clone();
        rig
          ..panScreenDelta(Vector2(40, -25))
          ..snap();
        expect(rig.target.distanceTo(targetBefore), greaterThan(0.1));
      },
    );

    test(
      'supports Z-up coordinate systems and frames any Aabb3 via fitAabb',
      () {
        final camera = CameraComponent3D(
          fovY: 55,
          viewport: FixedSizeViewport(1280, 720),
        );
        final rig = OrbitCameraController3D(
          camera: camera,
          upAxis: Vector3(0, 0, 1),
          yaw: 0.6,
          pitch: 0.45,
        );

        final bounds = Aabb3.minMax(
          Vector3(-6, 4, -2),
          Vector3(10, 18, 5),
        );
        rig.fitAabb(bounds);

        expect(camera.up, closeToVector3(Vector3(0, 0, 1), 1e-5));
        expect(camera.target, closeToVector3(Vector3(2, 11, 1.5), 1e-5));

        final frustum = camera.frustum;
        for (var mask = 0; mask < 8; mask++) {
          final corner = Vector3(
            (mask & 1) == 0 ? bounds.min.x : bounds.max.x,
            (mask & 2) == 0 ? bounds.min.y : bounds.max.y,
            (mask & 4) == 0 ? bounds.min.z : bounds.max.z,
          );
          expect(frustum.containsVector3(corner), isTrue);
        }
      },
    );
  });

  group('SpringArmCamera3D', () {
    test(
      'pulls camera in immediately against wall and recovers smoothly',
      () {
        final player = MeshComponent(
          mesh: CuboidMesh(size: Vector3.all(1)),
          position: Vector3.zero(),
        );
        final wall = MeshComponent(
          mesh: CuboidMesh(size: Vector3(8, 8, 1)),
          position: Vector3(0, 1, 3.5),
        );
        final world = World3D(children: [player, wall]);
        final camera = CameraComponent3D(
          world: world,
          viewport: FixedSizeViewport(800, 600),
        );
        final springArm = SpringArmCamera3D(
          camera: camera,
          world: world,
          targetComponent: player,
          socketOffset: Vector3(0, 1, 0),
          armLength: 8.0,
          probeRadius: 0.3,
          recoverySpeed: 6.0,
          pitch: 0,
        )..update(1 / 60);

        expect(springArm.isOccluded, isTrue);
        expect(springArm.currentArmLength, closeTo(2.7, 1e-4));
        expect(camera.position, closeToVector3(Vector3(0, 1, 2.7), 1e-4));
        expect(camera.target, closeToVector3(Vector3(0, 1, 0), 1e-5));

        wall.position.setValues(50, 1, 3.5);
        springArm.update(0.1);
        expect(springArm.isOccluded, isFalse);
        expect(springArm.currentArmLength, greaterThan(3.5));
        expect(springArm.currentArmLength, lessThan(7.8));

        for (var i = 0; i < 60; i++) {
          springArm.update(0.05);
        }
        expect(springArm.currentArmLength, closeTo(8.0, 1e-3));
        expect(camera.position, closeToVector3(Vector3(0, 1, 8), 1e-3));
      },
    );

    test('honors custom collisionFilter when ignoring non-blocking props', () {
      final glassProp = MeshComponent(
        mesh: CuboidMesh(size: Vector3(4, 4, 0.5)),
        position: Vector3(0, 0, 2),
      );
      final world = World3D(children: [glassProp]);
      final camera = CameraComponent3D(viewport: FixedSizeViewport(800, 600));
      final springArm = SpringArmCamera3D(
        camera: camera,
        world: world,
        target: Vector3.zero(),
        armLength: 6.0,
        pitch: 0,
        collisionFilter: (obj) => !identical(obj, glassProp),
      )..update(1 / 60);

      expect(springArm.isOccluded, isFalse);
      expect(springArm.currentArmLength, closeTo(6.0, 1e-5));
    });
  });

  group('CameraShake3D', () {
    test(
      'applies quadratic 6-DOF shake and restores exact base pose on decay',
      () {
        final baseEye = Vector3(2, 4, 12);
        final baseTarget = Vector3(2, 1, 0);
        final camera = CameraComponent3D(
          position: baseEye,
          target: baseTarget,
          viewport: FixedSizeViewport(800, 600),
        );
        final shake = CameraShake3D(
          camera: camera,
          traumaDecay: 1.0,
          maxPositionOffset: 0.5,
          maxAngleRad: 0.08,
        )..addTrauma(0.5);

        expect(shake.trauma, closeTo(0.5, 1e-6));
        expect(shake.shakeIntensity, closeTo(0.25, 1e-6));

        shake.addTrauma(0.9);
        expect(shake.trauma, closeTo(1.0, 1e-6));

        shake.update(0.1);
        expect(shake.trauma, closeTo(0.9, 1e-6));
        expect(shake.shakeIntensity, closeTo(0.81, 1e-6));
        expect(camera.position.distanceTo(baseEye), greaterThan(1e-3));
        expect(camera.target.distanceTo(baseTarget), greaterThan(1e-3));

        for (var i = 0; i < 12; i++) {
          shake.update(0.1);
        }
        expect(shake.trauma, 0.0);
        expect(camera.position, closeToVector3(baseEye, 1e-5));
        expect(camera.target, closeToVector3(baseTarget, 1e-5));
        expect(camera.up, closeToVector3(Vector3(0, 1, 0), 1e-5));
      },
    );
  });

  group('CameraDollyTrack3D', () {
    test('traverses eyeSpline and lookAtSpline with cubic easing and loop', () {
      final eyeSpline = CatmullRomSpline3D([
        Vector3(0, 2, 10),
        Vector3(5, 4, 5),
        Vector3(10, 2, 0),
      ]);
      final lookSpline = CatmullRomSpline3D([
        Vector3(0, 0, 0),
        Vector3(0, 1, -2),
        Vector3(0, 0, -4),
      ]);
      final camera = CameraComponent3D(viewport: FixedSizeViewport(800, 600));

      var completedCount = 0;
      final dolly = CameraDollyTrack3D(
        eyeSpline: eyeSpline,
        lookAtSpline: lookSpline,
        camera: camera,
        duration: 2.0,
        onComplete: () => completedCount++,
      );

      expect(camera.position, closeToVector3(Vector3(0, 2, 10), 1e-5));
      expect(camera.target, closeToVector3(Vector3(0, 0, 0), 1e-5));

      dolly.update(0.5);
      expect(dolly.progress, closeTo(0.25, 1e-6));
      expect(
        camera.position,
        closeToVector3(eyeSpline.samplePoint(0.15625), 1e-4),
      );
      expect(
        camera.target,
        closeToVector3(lookSpline.samplePoint(0.15625), 1e-4),
      );

      dolly.update(1.5);
      expect(dolly.progress, closeTo(1.0, 1e-6));
      expect(dolly.isCompleted, isTrue);
      expect(completedCount, 1);
      expect(camera.position, closeToVector3(Vector3(10, 2, 0), 1e-5));
      expect(camera.target, closeToVector3(Vector3(0, 0, -4), 1e-5));

      dolly
        ..loop = true
        ..cubicEasing = false
        ..reset()
        ..update(2.5);
      expect(dolly.progress, closeTo(0.25, 1e-6));
      expect(
        camera.position,
        closeToVector3(eyeSpline.samplePoint(0.25), 1e-4),
      );
    });
  });
}
