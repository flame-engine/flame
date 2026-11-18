import 'dart:math';

import 'package:flame_3d/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Transform3D', () {
    test('x, y and z setters write the given value', () {
      final transform = Transform3D()
        ..x = 1
        ..y = 2
        ..z = 3;

      expect(transform.position, Vector3(1, 2, 3));
      expect(transform.z, 3);
      expect(transform.transformMatrix.getTranslation(), Vector3(1, 2, 3));

      transform.z = -7;
      expect(transform.position.z, -7);
      expect(transform.transformMatrix.getTranslation().z, -7);
    });

    test('the default rotation is the identity quaternion', () {
      final transform = Transform3D();

      expect(transform.rotation, Quaternion.identity());
      expect(
        transform.rotation.rotated(Vector3(1, 2, 3)),
        closeToVector3(Vector3(1, 2, 3), 1e-6),
      );
      expect(transform.closeTo(Transform3D.compose()), isTrue);
    });

    test('setFromMatrix4 notifies the listeners of every part', () {
      final transform = Transform3D();
      var positionNotifications = 0;
      var rotationNotifications = 0;
      var scaleNotifications = 0;
      transform.position.addListener(() => positionNotifications++);
      transform.rotation.addListener(() => rotationNotifications++);
      transform.scale.addListener(() => scaleNotifications++);

      final matrix = Matrix4.compose(
        Vector3(1, 2, 3),
        Quaternion.axisAngle(Vector3(0, 1, 0), 0.5),
        Vector3(4, 5, 6),
      );
      transform.setFromMatrix4(matrix);

      expect(positionNotifications, 1);
      expect(rotationNotifications, 1);
      expect(scaleNotifications, 1);
      expect(transform.position, closeToVector3(Vector3(1, 2, 3), 1e-6));
      expect(transform.scale, closeToVector3(Vector3(4, 5, 6), 1e-5));
    });

    test('setFromMatrix4 leaves a consistent matrix for listeners', () {
      final transform = Transform3D();
      final matrix = Matrix4.compose(
        Vector3(1, 2, 3),
        Quaternion.axisAngle(Vector3(0, 0, 1), 1),
        Vector3(2, 3, 4),
      );
      Matrix4? lastSeen;
      transform.addListener(() => lastSeen = transform.transformMatrix.clone());

      transform.setFromMatrix4(matrix);

      expect(lastSeen, closeToMatrix4(matrix, 1e-5));
      expect(transform.transformMatrix, closeToMatrix4(matrix, 1e-5));
    });

    test('closeTo treats q and -q as the same rotation', () {
      final a = Transform3D()
        ..rotation = Quaternion.axisAngle(Vector3(0, 1, 0), 0.3);
      // A rotation by 0.3 + 2π has the negated quaternion.
      final b = Transform3D()
        ..rotation = Quaternion.axisAngle(Vector3(0, 1, 0), 0.3 + 2 * pi);
      expect(b.rotation.w, isNegative);

      expect(a.closeTo(b, tolerance: 1e-6), isTrue);
      expect(
        a.closeTo(
          Transform3D()..rotation = Quaternion.axisAngle(Vector3(0, 1, 0), 0.4),
          tolerance: 1e-6,
        ),
        isFalse,
      );
    });
  });
}
