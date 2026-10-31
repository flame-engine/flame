import 'package:flame_3d/camera.dart';
import 'package:flame_3d/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CameraComponent3D', () {
    CameraComponent3D lookingAtOrigin() => CameraComponent3D(
      position: Vector3(0, 0, 10),
      target: Vector3.zero(),
      viewport: FixedResolutionViewport(resolution: Vector2(800, 600)),
    );

    test('follows the camera while no frustum is held', () {
      final camera = lookingAtOrigin();
      expect(camera.frustum.containsVector3(Vector3.zero()), isTrue);

      camera.target.setValues(0, 0, 20);

      expect(camera.frustum.containsVector3(Vector3.zero()), isFalse);
    });

    test('keeps a held frustum until every hold is released', () {
      final camera = lookingAtOrigin()
        ..holdFrustum()
        ..holdFrustum();
      camera.target.setValues(0, 0, 20);

      expect(camera.frustum.containsVector3(Vector3.zero()), isTrue);
      camera.releaseFrustum();
      expect(camera.frustum.containsVector3(Vector3.zero()), isTrue);
      camera.releaseFrustum();
      expect(camera.frustum.containsVector3(Vector3.zero()), isFalse);
    });
  });
}
