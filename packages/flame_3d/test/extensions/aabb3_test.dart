import 'dart:math';

import 'package:flame_3d/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart' show Frustum;

void main() {
  group('CullResult', () {
    group('frustumCullTest', () {
      late Frustum frustum;

      setUp(() {
        // Build a standard perspective frustum from a view-projection matrix.
        // Camera at origin looking down -Z, 90-degree FOV, near=0.1, far=100.
        final projection = Matrix4.identity()
          ..setEntry(0, 0, 1 / tan((90 * degrees2Radians) / 2))
          ..setEntry(1, 1, 1)
          ..setEntry(2, 2, -(100 + 0.1) / (100 - 0.1))
          ..setEntry(2, 3, -(2 * 100 * 0.1) / (100 - 0.1))
          ..setEntry(3, 2, -1)
          ..setEntry(3, 3, 0);
        final view = Matrix4.identity();
        final viewProjection = projection.multiplied(view);
        frustum = Frustum()..setFromMatrix(viewProjection);
      });

      test('returns outside for AABB fully behind camera', () {
        // AABB at z = +5 to +10 (behind camera looking at -Z)
        final aabb = Aabb3.minMax(
          Vector3(-1, -1, 5),
          Vector3(1, 1, 10),
        );
        expect(aabb.frustumCullTest(frustum), CullResult.outside);
      });

      test('returns outside for AABB far to the left', () {
        // AABB far to the left of the frustum, in front of camera
        final aabb = Aabb3.minMax(
          Vector3(-100, -1, -10),
          Vector3(-50, 1, -5),
        );
        expect(aabb.frustumCullTest(frustum), CullResult.outside);
      });

      test('returns outside for AABB beyond far plane', () {
        // AABB way beyond the far plane
        final aabb = Aabb3.minMax(
          Vector3(-1, -1, -200),
          Vector3(1, 1, -150),
        );
        expect(aabb.frustumCullTest(frustum), CullResult.outside);
      });

      test('returns inside for small AABB centered in view', () {
        // Small AABB well inside the frustum
        final aabb = Aabb3.minMax(
          Vector3(-0.1, -0.1, -5.1),
          Vector3(0.1, 0.1, -4.9),
        );
        expect(aabb.frustumCullTest(frustum), CullResult.inside);
      });

      test('returns intersecting for AABB crossing near plane', () {
        // AABB that spans the near plane
        final aabb = Aabb3.minMax(
          Vector3(-0.5, -0.5, -1),
          Vector3(0.5, 0.5, 0.5),
        );
        expect(aabb.frustumCullTest(frustum), CullResult.intersecting);
      });

      test('returns intersecting for AABB crossing frustum edge', () {
        // AABB partially inside, partially outside the right edge
        // At z=-5, the frustum width is ~5 on each side (90-degree FOV)
        final aabb = Aabb3.minMax(
          Vector3(3, -1, -6),
          Vector3(7, 1, -4),
        );
        expect(aabb.frustumCullTest(frustum), CullResult.intersecting);
      });
    });
  });

  group('Aabb3Extension', () {
    test('setFrom copies min and max', () {
      final source = Aabb3.minMax(
        Vector3(1, 2, 3),
        Vector3(4, 5, 6),
      );
      final target = Aabb3();
      target.setFrom(source);

      expect(target.min.x, 1);
      expect(target.min.y, 2);
      expect(target.min.z, 3);
      expect(target.max.x, 4);
      expect(target.max.y, 5);
      expect(target.max.z, 6);
    });

    test('setZero resets to origin', () {
      final aabb = Aabb3.minMax(
        Vector3(1, 2, 3),
        Vector3(4, 5, 6),
      );
      aabb.setZero();

      expect(aabb.min.x, 0);
      expect(aabb.min.y, 0);
      expect(aabb.min.z, 0);
      expect(aabb.max.x, 0);
      expect(aabb.max.y, 0);
      expect(aabb.max.z, 0);
    });
  });
}
