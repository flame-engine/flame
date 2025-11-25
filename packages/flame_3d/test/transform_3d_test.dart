import 'package:flame_3d/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

const epsilon = 1e-6;

void main() {
  group('Transform3D', () {
    test('position, rotation and scale can be composed and decomposed', () {
      final position = Vector3(1, 2, 3);
      final rotation = Quaternion(0.1, 0.2, 0.3, 0.4).normalized();
      final scale = Vector3(4, 5, 6);

      final matrix = Matrix4.compose(position, rotation, scale);

      final transform = Transform3D.fromMatrix4(matrix);
      expect(transform.position, closeToVector3(position, epsilon));
      expect(transform.rotation, closeToQuaternion(rotation, epsilon));
      expect(transform.scale, closeToVector3(scale, epsilon));
    });

    test('can set from matrix or transform', () {
      final transform = Transform3D();

      final matrix1 = Matrix4.compose(
        Vector3(1, 2, 3),
        Quaternion(0.1, 0.2, 0.3, 0.4).normalized(),
        Vector3(4, 5, 6),
      );

      transform.setFromMatrix4(matrix1);
      expect(
        transform.transformMatrix,
        closeToMatrix4(matrix1, epsilon),
      );

      final matrix2 = Matrix4.compose(
        Vector3(7, 8, 9),
        Quaternion(0.5, 0.6, 0.7, 0.8).normalized(),
        Vector3(10, 11, 12),
      );
      transform.setFrom(Transform3D.fromMatrix4(matrix2));

      expect(
        transform.transformMatrix,
        closeToMatrix4(matrix2, epsilon),
      );
    });

    test('can create matrix4 using some parameters with sensible defaults', () {
      final matrix1 = Transform3D.matrix4(
        position: Vector3(1, 2, 3),
      );
      final transform1 = Transform3D.fromMatrix4(matrix1);
      expect(transform1.position, closeToVector3(Vector3(1, 2, 3), epsilon));
      expect(
        transform1.rotation,
        closeToQuaternion(Quaternion.identity(), epsilon),
      );
      expect(transform1.scale, closeToVector3(Vector3.all(1), epsilon));

      final transform2 = Transform3D.compose(
        rotation: Quaternion(0.1, 0.2, 0.3, 0.4).normalized(),
      );
      expect(transform2.position, closeToVector3(Vector3.zero(), epsilon));
      expect(
        transform2.rotation,
        closeToQuaternion(Quaternion(0.1, 0.2, 0.3, 0.4).normalized(), epsilon),
      );
      expect(transform2.scale, closeToVector3(Vector3.all(1), epsilon));

      final matrix3 = Transform3D.matrix4(
        scale: Vector3(4, 5, 6),
      );
      final transform3 = Transform3D()..setFromMatrix4(matrix3);
      expect(transform3.position, closeToVector3(Vector3.zero(), epsilon));
      expect(
        transform3.rotation,
        closeToQuaternion(Quaternion.identity(), epsilon),
      );
      expect(transform3.scale, closeToVector3(Vector3(4, 5, 6), epsilon));
    });
  });
}
