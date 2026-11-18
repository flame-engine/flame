import 'package:flame_3d/camera.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RayExtension.intersectsWithPlane', () {
    final ground = Plane.normalconstant(Vector3(0, 0, 1), -2);

    test('returns the distance to the crossing point', () {
      final ray = Ray.originDirection(
        Vector3(1, 1, 10),
        Vector3(0, 0.6, -0.8),
      );

      final t = ray.intersectsWithPlane(ground);

      expect(t, closeTo(10, 1e-6));
      expect(ray.at(t!), closeToVector3(Vector3(1, 7, 2), 1e-5));
    });

    test('returns null for a parallel ray or a crossing behind it', () {
      final parallel = Ray.originDirection(
        Vector3(0, 0, 5),
        Vector3(1, 0, 0),
      );
      final away = Ray.originDirection(Vector3(0, 0, 5), Vector3(0, 0, 1));

      expect(parallel.intersectsWithPlane(ground), isNull);
      expect(away.intersectsWithPlane(ground), isNull);
    });
  });
}
