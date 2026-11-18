import 'dart:ui' show Rect;

import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Scene3DProjection.affine', () {
    // A board of cells drawn as dimetric 2D art, z up.
    Scene3DProjection board({Vector3? towardsViewer}) {
      return Scene3DProjection.affine(
        origin: Vector2(0, -18),
        xAxis: Vector2(44, 22),
        yAxis: Vector2(-44, 22),
        zAxis: Vector2(0, -53.889),
        towardsViewer: towardsViewer ?? Vector3(0.6124, 0.6124, 0.5),
        near: -100,
        far: 100,
      );
    }

    final points = [
      Vector3.zero(),
      Vector3(1, 0, 0),
      Vector3(0, 1, 0),
      Vector3(0, 0, 1),
      Vector3(2.5, -1, 0.75),
      Vector3(17.25, 33.5, 4),
      Vector3(-120, 75, -3),
    ];

    test('maps scene points through the images of the axes', () {
      final projection = board();
      for (final p in points) {
        final local = projection.scenePointToLocal(p);
        expect(local.x, closeTo((p.x - p.y) * 44, 1e-3));
        expect(local.y, closeTo((p.x + p.y) * 22 - 18 - p.z * 53.889, 1e-3));
      }
      expect(projection.isAffine, isTrue);
    });

    test('measures the depth along the line of sight', () {
      final projection = board();
      // The direction of the lines that map to one point, towards the
      // viewer.
      final toViewer = Vector3(44 * 53.889, 44 * 53.889, 2 * 44 * 22)
        ..normalize();
      expect(projection.depthOf(toViewer * 100), closeTo(0, 1e-6));
      expect(projection.depthOf(toViewer * -100), closeTo(1, 1e-6));
      expect(projection.depthOf(Vector3.zero()), closeTo(0.5, 1e-6));
      for (final p in points) {
        final nearer = p + toViewer * 3;
        expect(
          projection.scenePointToLocal(nearer),
          _closeToVector2(projection.scenePointToLocal(p)),
        );
        expect(
          projection.depthOf(nearer),
          closeTo(projection.depthOf(p) - 3 / 200, 1e-6),
        );
      }
    });

    test('turns local points into the lines of sight through them', () {
      final projection = board();
      final toViewer = Vector3(44 * 53.889, 44 * 53.889, 2 * 44 * 22)
        ..normalize();
      for (final local in [
        Vector2.zero(),
        Vector2(13.7, -42.25),
        Vector2(-880, 1320.5),
      ]) {
        final ray = projection.localPointToRay(local);
        expect(ray.direction.length, closeTo(1, 1e-6));
        expect(ray.direction, _closeToVector3(-toViewer));
        expect(projection.depthOf(ray.origin), closeTo(0, 1e-6));
        for (final t in [0.0, 1.0, 37.5, 200.0]) {
          expect(
            projection.scenePointToLocal(ray.at(t)),
            _closeToVector2(local),
          );
        }
        expect(projection.depthOf(ray.at(200)), closeTo(1, 1e-6));
      }
    });

    test('is seen from the side of towardsViewer', () {
      final fromBelow = board(towardsViewer: Vector3(-1, -1, -1));
      final ray = fromBelow.localPointToRay(Vector2(10, 20));
      expect(ray.direction.z, greaterThan(0));
      expect(
        fromBelow.depthOf(Vector3(0, 0, 1)),
        greaterThan(fromBelow.depthOf(Vector3.zero())),
      );
      // Only the side matters, not the exact direction.
      expect(
        board(towardsViewer: Vector3(0, 0, 1)).sceneToLocalMatrix,
        board().sceneToLocalMatrix,
      );
    });

    test('puts the scene point at a depth on a local point', () {
      final projection = board();
      final local = Vector2(-31.5, 77.25);
      for (final depth in [0.0, 0.25, 1.0]) {
        final point = projection.localPointToScene(local, depth: depth);
        expect(projection.scenePointToLocal(point), _closeToVector2(local));
        expect(projection.depthOf(point), closeTo(depth, 1e-6));
      }
    });

    test('has an eye far away on the side of the viewer', () {
      final projection = board();
      final view = projection.viewMatrix;
      final eye = Matrix4.inverted(view).getTranslation();
      expect(projection.depthOf(eye), lessThan(-1));
      expect(
        projection.scenePointToLocal(eye),
        _closeToVector2(projection.scenePointToLocal(Vector3.zero())),
      );
      // A rigid transform.
      final rotation = view.getRotation();
      expect(rotation.determinant(), closeTo(1, 1e-5));
    });

    test('rejects what is not a projection', () {
      expect(
        () => Scene3DProjection.affine(
          xAxis: Vector2(1, 0),
          yAxis: Vector2(0, 1),
          zAxis: Vector2(0, -1),
          towardsViewer: Vector3(0, 1, 1),
          near: 1,
          far: 1,
        ),
        throwsArgumentError,
      );
      expect(
        () => Scene3DProjection.affine(
          xAxis: Vector2(1, 0),
          yAxis: Vector2(2, 0),
          zAxis: Vector2(-1, 0),
          towardsViewer: Vector3(0, 0, 1),
          near: -1,
          far: 1,
        ),
        throwsArgumentError,
      );
      // The lines of sight are along y + z; x is perpendicular to them.
      expect(
        () => Scene3DProjection.affine(
          xAxis: Vector2(1, 0),
          yAxis: Vector2(0, 1),
          zAxis: Vector2(0, -1),
          towardsViewer: Vector3(1, 0, 0),
          near: -1,
          far: 1,
        ),
        throwsArgumentError,
      );
    });
  });

  group('Scene3DProjection.perspective', () {
    const rect = Rect.fromLTWH(-30, 12, 320, 240);
    final eye = Vector3(3, -4, 5);
    final target = Vector3(0.5, 0.25, 0);
    final up = Vector3(0, 0, 1);

    Scene3DProjection perspective() {
      return Scene3DProjection.perspective(
        eye: eye,
        target: target,
        up: up,
        fovY: 55,
        rect: rect,
        near: 0.5,
        far: 50,
      );
    }

    CameraComponent3D camera() {
      return CameraComponent3D(
        position: eye,
        target: target,
        up: up,
        fovY: 55,
        near: 0.5,
        far: 50,
        viewport: FixedSizeViewport(rect.width, rect.height),
      );
    }

    final points = [
      Vector3.zero(),
      Vector3(1, 1, 0.5),
      Vector3(-2, 0.3, 1.5),
      Vector3(0.7, -1.4, -0.2),
    ];

    test('draws what a camera with the same settings shows', () {
      final projection = perspective();
      final reference = camera();
      expect(projection.isAffine, isFalse);
      for (final p in points) {
        final viewportPoint = reference.worldToViewportPoint(p);
        expect(
          projection.scenePointToLocal(p),
          _closeToVector2(viewportPoint + Vector2(rect.left, rect.top)),
        );
      }
    });

    test('turns local points into the rays of the camera', () {
      final projection = perspective();
      final reference = camera();
      for (final viewportPoint in [
        Vector2(160, 120),
        Vector2(3, 7),
        Vector2(311, 220),
      ]) {
        final expected = reference.viewportPointToRay(viewportPoint);
        final ray = projection.localPointToRay(
          viewportPoint + Vector2(rect.left, rect.top),
        );
        expect(ray.origin, _closeToVector3(expected.origin, 1e-4));
        expect(ray.direction, _closeToVector3(expected.direction, 1e-4));
        expect(projection.depthOf(ray.at(3)), inExclusiveRange(0, 1));
      }
    });

    test('equals the camera of the same matrices', () {
      final reference = camera();
      final projection = Scene3DProjection.camera(
        viewMatrix: reference.viewMatrix,
        projectionMatrix: reference.projectionMatrix,
        rect: rect,
      );
      for (final p in points) {
        expect(
          projection.scenePointToLocal(p),
          _closeToVector2(perspective().scenePointToLocal(p)),
        );
      }
      final viewEye = Matrix4.inverted(projection.viewMatrix).getTranslation();
      expect(viewEye, _closeToVector3(eye, 1e-4));
    });
  });

  group('Scene3DProjection.matrix', () {
    test('keeps the mapping of the matrix', () {
      final affine = Scene3DProjection.affine(
        xAxis: Vector2(30, 10),
        yAxis: Vector2(-20, 15),
        zAxis: Vector2(0, -40),
        towardsViewer: Vector3(1, 1, 1),
        near: -10,
        far: 10,
      );
      final copy = Scene3DProjection.matrix(affine.sceneToLocalMatrix);
      final point = Vector3(1.5, -2, 0.5);
      expect(
        copy.scenePointToLocal(point),
        _closeToVector2(affine.scenePointToLocal(point), 1e-4),
      );
      expect(copy.depthOf(point), closeTo(affine.depthOf(point), 1e-6));
      expect(copy.isAffine, isTrue);
      // The eye is derived on the side where the depth decreases.
      final eye = Matrix4.inverted(copy.viewMatrix).getTranslation();
      expect(copy.depthOf(eye), lessThan(0));
    });

    test('derives the center of projection of a perspective matrix', () {
      final eye = Vector3(1, 2, 8);
      final perspective = Scene3DProjection.perspective(
        eye: eye,
        target: Vector3.zero(),
        rect: const Rect.fromLTWH(0, 0, 100, 100),
      );
      final copy = Scene3DProjection.matrix(perspective.sceneToLocalMatrix);
      final derived = Matrix4.inverted(copy.viewMatrix).getTranslation();
      expect(derived, _closeToVector3(eye, 1e-3));
    });

    test('uses the given view matrix', () {
      final view = Matrix4.translationValues(-1, -2, -3);
      final projection = Scene3DProjection.matrix(
        Matrix4.identity()..setEntry(2, 2, 0.1),
        viewMatrix: view,
      );
      expect(projection.viewMatrix, view);
      expect(
        projection.scenePointToLocal(Vector3(4, 5, 6)),
        _closeToVector2(Vector2(4, 5)),
      );
    });
  });

  group('Scene3DComponent', () {
    final projection = Scene3DProjection.affine(
      xAxis: Vector2(32, 16),
      yAxis: Vector2(-32, 16),
      zAxis: Vector2(0, -40),
      towardsViewer: Vector3(1, 1, 1),
      near: -50,
      far: 50,
    );

    test('ties scene points and local points through its projection', () {
      final layer = Scene3DComponent(projection: projection);
      final point = Vector3(3, -2, 1.5);
      expect(
        layer.scenePointToLocal(point),
        _closeToVector2(projection.scenePointToLocal(point)),
      );
      final local = Vector2(12, -7);
      final ray = layer.localPointToRay(local);
      expect(layer.scenePointToLocal(ray.at(4)), _closeToVector2(local));

      final output = Vector2.zero();
      expect(
        identical(layer.scenePointToLocal(point, output: output), output),
        isTrue,
      );
    });

    test('owns its world and forwards the render scale to it', () {
      final world = World3D();
      final layer = Scene3DComponent(
        projection: projection,
        world: world,
        renderScale: 0.5,
      );
      expect(identical(layer.world, world), isTrue);
      expect(world.renderScale, 0.5);
      layer.renderScale = 0.75;
      expect(world.renderScale, 0.75);
      expect(layer.msaaSampleCount, 1);
      layer.msaa = Msaa.sample4;
      expect(layer.msaaSampleCount, 4);
      expect(() => layer.maxTextureSize = 32, throwsArgumentError);
    });

    testWithFlameGame('hosts its world', (game) async {
      final layer = Scene3DComponent(projection: projection);
      final box = _Box();
      layer.world.add(box);
      await game.world.ensureAdd(layer);
      await game.ready();

      expect(layer.world.parent, layer);
      expect(identical(layer.world.host, layer), isTrue);
      expect(identical(box.worldRef, layer.world), isTrue);
      expect(layer.world.isRendering, isFalse);
    });

    testWithFlameGame('is required by a world outside a 3D game', (
      game,
    ) async {
      final world = World3D();
      await game.ensureAdd(world);
      expect(() => world.host, throwsStateError);
    });
  });
}

class _Box() extends Object3D {
  @override
  void draw(RenderContext context) {}
}

Matcher _closeToVector2(Vector2 expected, [double epsilon = 1e-3]) {
  return predicate<Vector2>(
    (actual) =>
        (actual.x - expected.x).abs() <= epsilon &&
        (actual.y - expected.y).abs() <= epsilon,
    'within $epsilon of $expected',
  );
}

Matcher _closeToVector3(Vector3 expected, [double epsilon = 1e-5]) {
  return predicate<Vector3>(
    (actual) =>
        (actual.x - expected.x).abs() <= epsilon &&
        (actual.y - expected.y).abs() <= epsilon &&
        (actual.z - expected.z).abs() <= epsilon,
    'within $epsilon of $expected',
  );
}
