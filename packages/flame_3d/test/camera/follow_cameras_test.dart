import 'dart:math';

import 'package:flame_3d/camera.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FirstPersonCamera', () {
    test('puts the eye on the followed point and looks along rotation', () {
      final following = Vector3(1, 2, 3);
      final camera = FirstPersonCamera(
        following: following,
        rotation: Quaternion.axisAngle(Vector3(0, 1, 0), pi / 2),
        viewport: FixedSizeViewport(800, 600),
      );
      final version = camera.version;

      camera.update(1 / 60);

      expect(camera.position, following);
      expect(camera.target, closeToVector3(Vector3(0, 2, 3), 1e-6));
      expect(camera.eyePosition, following);
      expect(camera.version, greaterThan(version));
      // The target is straight ahead in view space.
      expect(
        camera.viewMatrix.transformed3(camera.target),
        closeToVector3(Vector3(0, 0, -1), 1e-6),
      );
    });

    test('follows a point that moves in place', () {
      final following = Vector3.zero();
      final camera = FirstPersonCamera(
        following: following,
        viewport: FixedSizeViewport(800, 600),
      )..update(0);
      final version = camera.version;

      following.setValues(4, 0, 0);
      camera.update(0);

      expect(camera.version, greaterThan(version));
      expect(camera.eyePosition, Vector3(4, 0, 0));
      expect(camera.frustum.containsVector3(Vector3(4, 0, -10)), isTrue);
      expect(camera.frustum.containsVector3(Vector3(0, 0, -0.5)), isFalse);
    });

    test('passes the projection settings on', () {
      final camera = FirstPersonCamera(
        following: Vector3.zero(),
        projection: CameraProjection.orthographic,
        orthographicHeight: 4,
        near: -1,
        far: 9,
      );

      expect(camera.orthographicHeight, 4);
      expect(camera.near, -1);
      expect(camera.far, 9);
    });
  });

  group('ThirdPersonCamera', () {
    test('moves towards the point behind the followed one', () {
      final following = Vector3(1, 0, 0);
      final camera = ThirdPersonCamera(
        following: following,
        position: Vector3(1, 0, 0),
        viewport: FixedSizeViewport(800, 600),
      );

      // Half of the way with followDamping 1 and dt 0.5.
      camera.update(0.5);
      expect(camera.position, closeToVector3(Vector3(1, 0, 2.5), 1e-6));
      expect(camera.target, following);

      camera.update(1);
      expect(camera.position, closeToVector3(Vector3(1, 0, 5), 1e-6));
      expect(camera.eyePosition, closeToVector3(Vector3(1, 0, 5), 1e-6));
      expect(camera.frustum.containsVector3(following), isTrue);
    });

    test('keeps the distance along its rotation', () {
      final camera = ThirdPersonCamera(
        following: Vector3.zero(),
        rotation: Quaternion.axisAngle(Vector3(0, 1, 0), pi / 2),
        viewport: FixedSizeViewport(800, 600),
      )..distance = 3;

      camera.update(1);

      expect(camera.position, closeToVector3(Vector3(3, 0, 0), 1e-6));
    });

    test('passes the projection settings on', () {
      final camera = ThirdPersonCamera(
        following: Vector3.zero(),
        orthographicHeight: 4,
        near: 0.5,
        far: 9,
      );

      expect(camera.orthographicHeight, 4);
      expect(camera.near, 0.5);
      expect(camera.far, 9);
    });
  });
}
