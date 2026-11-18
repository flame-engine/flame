import 'dart:math' as math;

import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Matcher closeToVector(double x, double y, double z) {
    return isA<Vector3>()
        .having((v) => v.x, 'x', closeTo(x, 1e-6))
        .having((v) => v.y, 'y', closeTo(y, 1e-6))
        .having((v) => v.z, 'z', closeTo(z, 1e-6));
  }

  group('Light.direction', () {
    test('is the normalized explicit direction of a directional light', () {
      final light = Light(
        position: Vector3.zero(),
        source: DirectionalLight(direction: Vector3(3, 0, -4)),
        transform: Matrix4.rotationY(1),
      );

      expect(light.direction(), closeToVector(0.6, 0, -0.8));
    });

    test('is the -Z axis of the transform without explicit direction', () {
      final light = Light(
        position: Vector3.zero(),
        source: DirectionalLight(),
        transform: Matrix4.rotationY(math.pi / 2)..scaleByDouble(2, 2, 2, 1),
      );

      // -Z turned a quarter turn around +Y points to -X.
      expect(light.direction(), closeToVector(-1, 0, 0));
    });

    test('points down without direction nor transform', () {
      final light = Light(position: Vector3.zero(), source: DirectionalLight());

      expect(light.direction(), closeToVector(0, -1, 0));
    });

    test('writes into the given vector', () {
      final out = Vector3.zero();
      final light = Light(
        position: Vector3.zero(),
        source: DirectionalLight(direction: Vector3(0, 0, 2)),
      );

      expect(identical(light.direction(out), out), isTrue);
      expect(out, closeToVector(0, 0, 1));
    });
  });

  group('LightComponent', () {
    test('a directional light follows the rotation of the component', () {
      final component = LightComponent.directional(
        rotation: Quaternion.axisAngle(Vector3(1, 0, 0), -math.pi / 2),
      );

      expect(component.light.direction(), closeToVector(0, -1, 0));

      component.rotation.setAxisAngle(Vector3(0, 1, 0), math.pi / 2);
      component.worldTransformMatrix;
      expect(component.light.direction(), closeToVector(-1, 0, 0));
    });

    test('an explicit direction wins over the rotation', () {
      final component = LightComponent.directional(
        direction: Vector3(0, 0, -1),
        rotation: Quaternion.axisAngle(Vector3(1, 0, 0), 1),
      );

      expect(component.light.direction(), closeToVector(0, 0, -1));
    });

    test('creates each kind of light', () {
      final point = LightComponent.point(intensity: 2, range: 5);
      final hemisphere = LightComponent.hemisphere(
        up: Vector3(0, 0, 1),
        intensity: 0.4,
      );

      expect(
        point.source,
        isA<PointLight>()
            .having((l) => l.intensity, 'intensity', 2)
            .having((l) => l.range, 'range', 5),
      );
      expect(
        hemisphere.source,
        isA<HemisphereLight>()
            .having((l) => l.up, 'up', Vector3(0, 0, 1))
            .having((l) => l.intensity, 'intensity', 0.4),
      );
      expect(LightComponent.ambient().source, isA<AmbientLight>());
    });
  });
}
