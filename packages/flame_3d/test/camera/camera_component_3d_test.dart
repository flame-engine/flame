import 'dart:math';

import 'package:flame_3d/camera.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

const _width = 800.0;
const _height = 600.0;

CameraComponent3D _camera({
  CameraProjection projection = CameraProjection.perspective,
  double fovY = 60,
  double? orthographicHeight,
  double near = CameraComponent3D.distanceNear,
  double far = CameraComponent3D.distanceFar,
  Vector3? position,
  Vector3? target,
  Vector3? up,
  Matrix4? customViewMatrix,
  Matrix4? customProjectionMatrix,
}) {
  return CameraComponent3D(
    projection: projection,
    fovY: fovY,
    orthographicHeight: orthographicHeight,
    near: near,
    far: far,
    position: position ?? Vector3(3, 4, 10),
    target: target ?? Vector3(0, 1, 0),
    up: up,
    customViewMatrix: customViewMatrix,
    customProjectionMatrix: customProjectionMatrix,
    viewport: FixedSizeViewport(_width, _height),
  );
}

Vector4 _clip(Matrix4 viewProjection, Vector3 p) =>
    viewProjection.transformed(Vector4(p.x, p.y, p.z, 1));

double _depth(Matrix4 viewProjection, Vector3 p) {
  final clip = _clip(viewProjection, p);
  return clip.z / clip.w;
}

/// A world point at [distance] from the eye along the view direction, offset
/// by [right] and [up] world units along the camera's axes.
Vector3 _pointAt(
  CameraComponent3D camera,
  double distance, {
  double right = 0,
  double up = 0,
}) {
  final inverse = camera.inverseViewMatrix;
  return inverse.transformed3(Vector3(right, up, -distance));
}

/// Distance from [point] to the line of [ray].
double _distanceToRay(Ray ray, Vector3 point) {
  final toPoint = point - ray.origin;
  return toPoint.cross(ray.direction).length;
}

/// A mirrored dimetric view: a look-at view of a space in which world x and y
/// are swapped (determinant -1, which no look-at view has).
Matrix4 _mirroredDimetricView() {
  final swapXY = Matrix4(
    0,
    1,
    0,
    0, //
    1,
    0,
    0,
    0, //
    0,
    0,
    1,
    0, //
    0,
    0,
    0,
    1, //
  );
  return Matrix4.zero()
    ..setAsViewMatrix(
      Vector3(0.6123724, 0.6123724, 0.5)..scale(20),
      Vector3.zero(),
      Vector3(0, 0, 1),
    )
    ..multiply(swapXY);
}

void main() {
  group('CameraComponent3D clip space', () {
    for (final projection in CameraProjection.values) {
      for (final (near, far) in [(0.01, 1000.0), (2.0, 50.0)]) {
        test('${projection.name} maps near to depth 0 and far to depth 1 '
            '(near $near, far $far)', () {
          final camera = _camera(
            projection: projection,
            orthographicHeight: 8,
            near: near,
            far: far,
          );
          final viewProjection = camera.viewProjectionMatrix;

          for (final (right, up) in [(0.0, 0.0), (0.5, -0.25), (-0.2, 0.3)]) {
            // Offsets scale with the distance for perspective so the points
            // stay inside the frustum.
            double scaled(double v, double d) =>
                projection == CameraProjection.perspective ? v * d : v;
            final onNear = _pointAt(
              camera,
              near,
              right: scaled(right, near),
              up: scaled(up, near),
            );
            final onFar = _pointAt(
              camera,
              far,
              right: scaled(right, far),
              up: scaled(up, far),
            );
            expect(_depth(viewProjection, onNear), closeTo(0, 1e-4));
            expect(_depth(viewProjection, onFar), closeTo(1, 1e-4));
          }
        });
      }
    }

    test('orthographic keeps an object anywhere between near and far', () {
      final camera = _camera(
        projection: CameraProjection.orthographic,
        orthographicHeight: 10,
        near: 1,
        far: 101,
      );

      for (final distance in [1.1, 2.0, 25.0, 50.0, 75.0, 99.0, 100.9]) {
        final center = _pointAt(camera, distance, right: 3, up: -2);
        final box = Aabb3.centerAndHalfExtents(center, Vector3.all(0.04));
        expect(camera.frustum.containsVector3(center), isTrue);
        expect(camera.frustum.intersectsWithAabb3(box), isTrue);
        expect(box.frustumCullTest(camera.frustum), CullResult.inside);
      }
      for (final distance in [0.9, 0.0, -5.0, 101.1, 500.0]) {
        final point = _pointAt(camera, distance);
        expect(camera.frustum.containsVector3(point), isFalse);
      }
    });

    test('orthographic accepts a negative near distance', () {
      final camera = _camera(
        projection: CameraProjection.orthographic,
        orthographicHeight: 10,
        near: -20,
        far: 20,
      );

      expect(camera.frustum.containsVector3(_pointAt(camera, -19)), isTrue);
      expect(camera.frustum.containsVector3(_pointAt(camera, 19)), isTrue);
      expect(camera.frustum.containsVector3(_pointAt(camera, -21)), isFalse);
      expect(
        _depth(camera.viewProjectionMatrix, _pointAt(camera, 0)),
        closeTo(0.5, 1e-6),
      );
    });

    test('perspective frustum starts at the near distance', () {
      final camera = _camera(near: 2, far: 50);

      expect(camera.frustum.containsVector3(_pointAt(camera, 1.9)), isFalse);
      expect(camera.frustum.containsVector3(_pointAt(camera, 2.1)), isTrue);
      expect(camera.frustum.containsVector3(_pointAt(camera, 49.9)), isTrue);
      expect(camera.frustum.containsVector3(_pointAt(camera, 50.1)), isFalse);
    });
  });

  group('CameraComponent3D orthographic height', () {
    test('is the full vertical extent of the view in world units', () {
      final camera = _camera(
        projection: CameraProjection.orthographic,
        orthographicHeight: 12,
        near: 1,
        far: 100,
      );
      const aspect = _width / _height;

      final top = camera.worldToViewportPoint(_pointAt(camera, 10, up: 6));
      final bottom = camera.worldToViewportPoint(_pointAt(camera, 10, up: -6));
      final right = camera.worldToViewportPoint(
        _pointAt(camera, 10, right: 6 * aspect),
      );
      expect(top, closeToVector(Vector2(_width / 2, 0), 1e-3));
      expect(bottom, closeToVector(Vector2(_width / 2, _height), 1e-3));
      expect(right, closeToVector(Vector2(_width, _height / 2), 1e-3));
    });

    test('falls back to fovY when null, as before', () {
      final legacy = _camera(
        projection: CameraProjection.orthographic,
        fovY: 12,
      );
      final explicit = _camera(
        projection: CameraProjection.orthographic,
        fovY: 99,
        orthographicHeight: 12,
      );

      expect(
        legacy.projectionMatrix,
        closeToMatrix4(explicit.projectionMatrix, 1e-7),
      );
    });

    test('is ignored by the perspective projection', () {
      final a = _camera(orthographicHeight: 3);
      final b = _camera(orthographicHeight: 300);

      expect(a.projectionMatrix, b.projectionMatrix);
    });
  });

  group('CameraComponent3D caching', () {
    test('repeated reads return the same objects and recompute nothing', () {
      final camera = _camera();
      final view = camera.viewMatrix;
      final projection = camera.projectionMatrix;
      final viewProjection = camera.viewProjectionMatrix;
      final inverseView = camera.inverseViewMatrix;
      final eye = camera.eyePosition;
      final frustum = camera.frustum;
      camera.viewportPointToRay(Vector2(10, 20));
      final version = camera.version;
      final updates = camera.matrixUpdateCount;

      for (var i = 0; i < 1000; i++) {
        expect(identical(camera.viewMatrix, view), isTrue);
        expect(identical(camera.projectionMatrix, projection), isTrue);
        expect(identical(camera.viewProjectionMatrix, viewProjection), isTrue);
        expect(identical(camera.inverseViewMatrix, inverseView), isTrue);
        expect(identical(camera.eyePosition, eye), isTrue);
        expect(identical(camera.frustum, frustum), isTrue);
        camera.viewportPointToRay(Vector2(10, 20));
        camera.worldToViewportPoint(Vector3(1, 2, 3));
      }

      expect(camera.version, version);
      expect(camera.matrixUpdateCount, updates);
    });

    test('a read recomputes only what it needs', () {
      final camera = _camera();
      camera.viewMatrix;
      final afterView = camera.matrixUpdateCount;
      expect(afterView, 1);

      camera.projectionMatrix;
      expect(camera.matrixUpdateCount, afterView + 1);

      camera.frustum;
      // The view-projection product and the frustum.
      expect(camera.matrixUpdateCount, afterView + 3);

      camera.position.x += 1;
      camera.viewMatrix;
      expect(camera.matrixUpdateCount, afterView + 4);
    });

    test('values are recomputed after a change', () {
      final camera = _camera(
        position: Vector3(0, 0, 10),
        target: Vector3.zero(),
      );
      expect(camera.eyePosition, Vector3(0, 0, 10));

      camera.position.setValues(5, 0, 10);

      expect(camera.eyePosition, Vector3(5, 0, 10));
      final expected = Matrix4.zero()
        ..setAsViewMatrix(Vector3(5, 0, 10), Vector3.zero(), Vector3(0, 1, 0));
      expect(camera.viewMatrix, closeToMatrix4(expected, 1e-6));
      expect(
        camera.viewProjectionMatrix,
        closeToMatrix4(camera.projectionMatrix.multiplied(expected), 1e-5),
      );
    });

    test('a modified returned matrix does not corrupt the cache', () {
      final camera = _camera();
      final expected = camera.viewMatrix.clone();
      final expectedProjection = camera.projectionMatrix.clone();

      camera.viewMatrix.setZero();
      camera.projectionMatrix.setIdentity();

      expect(camera.viewMatrix, expected);
      expect(camera.projectionMatrix, expectedProjection);
    });
  });

  group('CameraComponent3D version', () {
    void expectBump(
      CameraComponent3D camera,
      void Function() change, {
      int by = 1,
    }) {
      final before = camera.version;
      change();
      expect(camera.version, before + by);
      // Reading again without a change keeps it.
      expect(camera.version, before + by);
    }

    test('starts at 0 and does not change without input changes', () {
      final camera = _camera();
      expect(camera.version, 0);
      camera
        ..viewMatrix
        ..frustum
        ..eyePosition;
      expect(camera.version, 0);
    });

    test('increases once for each input change', () {
      final camera = _camera();
      expectBump(camera, () => camera.position.x += 1);
      expectBump(camera, () => camera.position = Vector3(7, 8, 9));
      expectBump(camera, () => camera.target.setValues(1, 1, 1));
      expectBump(camera, () => camera.target = Vector3(0, 2, 0));
      expectBump(camera, () => camera.up.setValues(1, 1, 0));
      expectBump(camera, () => camera.up = Vector3(0, 0, 1));
      expectBump(camera, () => camera.fovY = 45);
      expectBump(camera, () => camera.near = 0.5);
      expectBump(camera, () => camera.far = 500);
      expectBump(
        camera,
        () => camera.projection = CameraProjection.orthographic,
      );
      expectBump(camera, () => camera.orthographicHeight = 20);
      expectBump(camera, () => camera.viewport.size = Vector2(400, 300));
      expectBump(camera, () => camera.customViewMatrix = Matrix4.identity());
      expectBump(
        camera,
        () => camera.customProjectionMatrix = Matrix4.identity(),
      );
      expectBump(camera, () => camera.customViewMatrix!.setEntry(0, 3, 4));
      expectBump(
        camera,
        () => camera.customProjectionMatrix!.setEntry(1, 1, 2),
      );
      expectBump(camera, () => camera.customViewMatrix = null);
      expectBump(camera, () => camera.customProjectionMatrix = null);
      // Two changes between reads count twice for the setters.
      expectBump(
        camera,
        () => camera
          ..near = 1
          ..far = 900,
        by: 2,
      );
    });

    test('does not change when a value is set to what it already is', () {
      final camera = _camera(
        projection: CameraProjection.orthographic,
        orthographicHeight: 10,
      );
      final before = camera.version;

      camera
        ..position = camera.position.clone()
        ..target.setFrom(camera.target)
        ..up = camera.up.clone()
        ..near = camera.near
        ..far = camera.far
        ..orthographicHeight = 10
        ..projection = CameraProjection.orthographic
        ..viewport.size = Vector2(_width, _height);
      // A change that is undone before the next read is no change.
      camera.position.x += 1;
      camera.position.x -= 1;

      expect(camera.version, before);
    });

    test('ignores inputs the current matrices do not use', () {
      final orthographic = _camera(
        projection: CameraProjection.orthographic,
        orthographicHeight: 10,
      );
      var before = orthographic.version;
      orthographic.fovY = 30;
      expect(orthographic.version, before);

      final perspective = _camera();
      before = perspective.version;
      perspective.orthographicHeight = 3;
      expect(perspective.version, before);

      final customView = _camera(customViewMatrix: Matrix4.identity());
      before = customView.version;
      customView
        ..position.setValues(1, 2, 3)
        ..target.setValues(4, 5, 6);
      expect(customView.version, before);

      final customProjection = _camera(
        customProjectionMatrix: Matrix4.identity(),
      );
      before = customProjection.version;
      customProjection
        ..fovY = 10
        ..near = 3
        ..far = 4
        ..projection = CameraProjection.orthographic;
      expect(customProjection.version, before);
    });

    test('picks up look-at changes again after clearing a custom view', () {
      final camera = _camera(customViewMatrix: Matrix4.identity());
      camera.position.setValues(0, 0, 5);
      camera.target.setValues(0, 0, 0);
      camera.customViewMatrix = null;

      expect(camera.eyePosition, Vector3(0, 0, 5));
    });
  });

  group('CameraComponent3D custom matrices', () {
    test('a custom view sets the view, the eye and the frustum', () {
      final view = _mirroredDimetricView();
      final camera = _camera(
        projection: CameraProjection.orthographic,
        orthographicHeight: 10,
        near: 1,
        far: 100,
        customViewMatrix: view,
      );

      expect(camera.viewMatrix, closeToMatrix4(view, 0));
      // The look-at eye was at s * (0.61, 0.61, 0.5) in the swapped space,
      // which is the same point here since x and y are equal.
      final eye = Vector3(0.6123724, 0.6123724, 0.5)..scale(20);
      expect(camera.eyePosition, closeToVector3(eye, 1e-4));
      expect(
        camera.inverseViewMatrix.multiplied(view),
        closeToMatrix4(Matrix4.identity(), 1e-5),
      );
      expect(
        camera.viewProjectionMatrix,
        closeToMatrix4(camera.projectionMatrix.multiplied(view), 1e-5),
      );

      // The origin is ~20 units in front of the eye.
      expect(camera.frustum.containsVector3(Vector3.zero()), isTrue);
      expect(camera.frustum.containsVector3(Vector3(1, -1, 0)), isTrue);
      // Behind the eye and beyond the far plane.
      expect(camera.frustum.containsVector3(eye * 1.2), isFalse);
      expect(camera.frustum.containsVector3(eye * -5), isFalse);
    });

    test('a custom view with an eye off the swap plane', () {
      final swapXY = Matrix4(
        0,
        1,
        0,
        0, //
        1,
        0,
        0,
        0, //
        0,
        0,
        1,
        0, //
        0,
        0,
        0,
        1, //
      );
      final lookAtEye = Vector3(10, 2, 5);
      final view = Matrix4.zero()
        ..setAsViewMatrix(lookAtEye, Vector3.zero(), Vector3(0, 0, 1))
        ..multiply(swapXY);
      final camera = _camera(customViewMatrix: view);

      // V = L * S, so the eye is S^-1 applied to the look-at eye.
      expect(camera.eyePosition, closeToVector3(Vector3(2, 10, 5), 1e-5));
    });

    test('a custom projection drives the frustum', () {
      // A cabinet (oblique) projection: depth shifts x and y by half of it.
      final oblique = Matrix4.zero()
        ..setAsOrthographic(10, _width / _height, 1, 21)
        ..multiply(
          Matrix4.identity()
            ..setEntry(0, 2, -0.5 * cos(pi / 4))
            ..setEntry(1, 2, -0.5 * sin(pi / 4)),
        );
      final camera = _camera(customProjectionMatrix: oblique);
      expect(camera.projectionMatrix, closeToMatrix4(oblique, 0));

      final random = Random(7);
      var inside = 0;
      for (var i = 0; i < 500; i++) {
        final point = _pointAt(
          camera,
          random.nextDouble() * 24 - 2,
          right: random.nextDouble() * 20 - 10,
          up: random.nextDouble() * 14 - 7,
        );
        final clip = _clip(camera.viewProjectionMatrix, point);
        final expected =
            clip.x.abs() <= clip.w &&
            clip.y.abs() <= clip.w &&
            clip.z >= 0 &&
            clip.z <= clip.w;
        if (expected) {
          inside++;
        }
        // Stay away from the boundary, where float rounding decides.
        final margin = [
          clip.w - clip.x.abs(),
          clip.w - clip.y.abs(),
          clip.z,
          clip.w - clip.z,
        ].map((d) => d.abs()).reduce(min);
        if (margin > 1e-3) {
          expect(camera.frustum.containsVector3(point), expected);
        }
      }
      expect(inside, greaterThan(50));
    });

    test('a custom projection replaces the built-in settings', () {
      final projection = Matrix4.zero()
        ..setAsOrthographicOffCenter(-1, 3, -2, 2, 0, 10);
      final camera = _camera(customProjectionMatrix: projection);

      camera
        ..fovY = 10
        ..near = 3
        ..viewport.size = Vector2(10, 10000);

      expect(camera.projectionMatrix, closeToMatrix4(projection, 0));
    });
  });

  group('CameraComponent3D winding', () {
    double det3(Matrix4 m) => m.getRotation().determinant();

    test('a standard camera has a negative determinant', () {
      for (final projection in CameraProjection.values) {
        for (final position in [
          Vector3(3, 4, 10),
          Vector3(-5, 2, -1),
          Vector3(0, 10, 0.1),
        ]) {
          final camera = _camera(
            projection: projection,
            orthographicHeight: 10,
            position: position,
            target: Vector3.zero(),
          );
          final viewProjection = camera.viewProjectionMatrix;
          expect(det3(viewProjection), isNegative);
          expect(viewProjection.determinant(), isNegative);
        }
      }
    });

    test('a mirrored custom view or projection has a positive determinant', () {
      final mirroredView = _camera(
        projection: CameraProjection.orthographic,
        orthographicHeight: 10,
        customViewMatrix: _mirroredDimetricView(),
      );
      expect(det3(mirroredView.viewProjectionMatrix), isPositive);
      expect(mirroredView.viewProjectionMatrix.determinant(), isPositive);

      final mirroredProjection = _camera(
        customProjectionMatrix: Matrix4.diagonal3Values(-1, 1, 1)
          ..multiply(
            Matrix4.zero()..setAsPerspective(60, _width / _height, 1, 100),
          ),
      );
      expect(det3(mirroredProjection.viewProjectionMatrix), isPositive);
      expect(mirroredProjection.viewProjectionMatrix.determinant(), isPositive);
    });
  });

  group('CameraComponent3D rays and projection of points', () {
    final setups = <String, CameraComponent3D Function()>{
      'perspective': _camera,
      'perspective with custom near and far': () => _camera(near: 1, far: 60),
      'orthographic': () => _camera(
        projection: CameraProjection.orthographic,
        orthographicHeight: 14,
        near: -10,
        far: 60,
      ),
      'mirrored custom view': () => _camera(
        projection: CameraProjection.orthographic,
        orthographicHeight: 14,
        near: 1,
        far: 60,
        customViewMatrix: _mirroredDimetricView(),
      ),
      'mirrored custom view, perspective': () =>
          _camera(near: 1, far: 60, customViewMatrix: _mirroredDimetricView()),
      'custom oblique projection': () => _camera(
        customProjectionMatrix: Matrix4.zero()
          ..setAsOrthographic(14, _width / _height, 1, 60)
          ..multiply(
            Matrix4.identity()
              ..setEntry(0, 2, -0.35)
              ..setEntry(1, 2, -0.35),
          ),
      ),
    };

    for (final MapEntry(key: name, value: build) in setups.entries) {
      test('$name: world -> viewport -> ray passes through the point', () {
        final camera = build();
        final random = Random(name.hashCode);
        final eye = camera.eyePosition.clone();
        final ray = Ray();
        final viewportPoint = Vector2.zero();

        for (var i = 0; i < 200; i++) {
          final distance = 2 + random.nextDouble() * 50;
          final point = camera.inverseViewMatrix.transformed3(
            Vector3(
              (random.nextDouble() - 0.5) * 4,
              (random.nextDouble() - 0.5) * 4,
              -distance,
            ),
          );

          camera.worldToViewportPoint(point, output: viewportPoint);
          camera.viewportPointToRay(viewportPoint, output: ray);

          expect(ray.direction.length, closeTo(1, 1e-6));
          expect(_distanceToRay(ray, point), lessThan(2e-4));
          // The point lies ahead of the ray origin, away from the eye.
          expect((point - ray.origin).dot(ray.direction), isPositive);
          expect((ray.origin - eye).dot(ray.direction), greaterThan(-11));
        }
      });

      test('$name: viewport -> ray -> world -> viewport is the identity', () {
        final camera = build();
        final ray = Ray();
        for (final point in [
          Vector2(0, 0),
          Vector2(_width, _height),
          Vector2(_width / 2, _height / 2),
          Vector2(123.25, 456.5),
          Vector2(799, 1),
        ]) {
          camera.viewportPointToRay(point, output: ray);
          for (final t in [1.0, 17.0]) {
            expect(
              camera.worldToViewportPoint(ray.at(t)),
              closeToVector(point, 1e-3),
            );
          }
          // The origin is on the near plane.
          expect(
            _depth(camera.viewProjectionMatrix, ray.origin),
            closeTo(0, 1e-3),
          );
        }
      });
    }

    test('perspective rays start on the near plane and leave the eye', () {
      final camera = _camera(
        position: Vector3(0, 0, 10),
        target: Vector3.zero(),
        near: 0.5,
      );
      final ray = camera.viewportPointToRay(Vector2(_width / 2, _height / 2));

      expect(ray.origin, closeToVector3(Vector3(0, 0, 9.5), 1e-6));
      expect(ray.direction, closeToVector3(Vector3(0, 0, -1), 1e-6));

      // The top-left corner ray follows the frustum edge.
      final corner = camera.viewportPointToRay(Vector2.zero());
      final tanHalf = tan(30 * degrees2Radians);
      final expected = Vector3(-tanHalf * _width / _height, tanHalf, -1)
        ..normalize();
      expect(corner.direction, closeToVector3(expected, 1e-6));
    });

    test('orthographic rays are parallel to the view direction', () {
      final camera = _camera(
        projection: CameraProjection.orthographic,
        orthographicHeight: 10,
        position: Vector3(0, 0, 10),
        target: Vector3.zero(),
        near: 1,
      );

      final center = camera.viewportPointToRay(
        Vector2(_width / 2, _height / 2),
      );
      final topLeft = camera.viewportPointToRay(Vector2.zero());

      expect(center.direction, closeToVector3(Vector3(0, 0, -1), 1e-6));
      expect(topLeft.direction, closeToVector3(Vector3(0, 0, -1), 1e-6));
      expect(center.origin, closeToVector3(Vector3(0, 0, 9), 1e-6));
      expect(
        topLeft.origin,
        closeToVector3(Vector3(-5 * _width / _height, 5, 9), 1e-5),
      );
    });

    test('a ray picks a point on the ground plane', () {
      final camera = _camera(
        projection: CameraProjection.orthographic,
        orthographicHeight: 10,
        position: Vector3(10, 10, 10),
        target: Vector3(1, 2, 0),
        up: Vector3(0, 0, 1),
      );
      final ground = Plane.normalconstant(Vector3(0, 0, 1), 0);
      final tapped = camera.worldToViewportPoint(Vector3(4, -1, 0));

      final ray = camera.viewportPointToRay(tapped);
      final t = ray.intersectsWithPlane(ground)!;

      expect(ray.at(t), closeToVector3(Vector3(4, -1, 0), 1e-4));
    });

    test('projects known points of an orthographic camera', () {
      final camera = _camera(
        projection: CameraProjection.orthographic,
        orthographicHeight: 10,
        position: Vector3(0, 0, 10),
        target: Vector3.zero(),
      );

      expect(
        camera.worldToViewportPoint(Vector3.zero()),
        closeToVector(Vector2(400, 300), 1e-4),
      );
      expect(
        camera.worldToViewportPoint(Vector3(0, 5, 3)),
        closeToVector(Vector2(400, 0), 1e-4),
      );
      expect(
        camera.worldToViewportPoint(Vector3(-5 * _width / _height, -5, -7)),
        closeToVector(Vector2(0, 600), 1e-4),
      );
      // 60 logical pixels per world unit.
      expect(
        camera.worldToViewportPoint(Vector3(1, 1, 0)),
        closeToVector(Vector2(460, 240), 1e-4),
      );
    });

    testWithFlameGame('uses the viewport of a mounted camera', (game) async {
      final camera = CameraComponent3D(
        position: Vector3(0, 0, 10),
        target: Vector3.zero(),
      );
      await game.ensureAdd(camera);
      final size = camera.viewport.virtualSize;
      expect(size.x, greaterThan(0));

      final center = camera.viewportPointToRay(size / 2);
      expect(center.direction, closeToVector3(Vector3(0, 0, -1), 1e-6));
      expect(
        camera.worldToViewportPoint(Vector3.zero()),
        closeToVector(size / 2, 1e-4),
      );
    });
  });
}
