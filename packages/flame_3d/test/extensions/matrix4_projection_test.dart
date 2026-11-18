import 'dart:math';

import 'package:flame_3d/camera.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

/// Depth (z / w) of the view-space point [p] under [projection].
double _depthOf(Matrix4 projection, Vector3 p) {
  final clip = projection.transformed(Vector4(p.x, p.y, p.z, 1));
  return clip.z / clip.w;
}

Vector2 _ndcOf(Matrix4 projection, Vector3 p) {
  final clip = projection.transformed(Vector4(p.x, p.y, p.z, 1));
  return Vector2(clip.x / clip.w, clip.y / clip.w);
}

void main() {
  group('Matrix4Extension projections', () {
    test('setAsPerspective maps near to depth 0 and far to depth 1', () {
      const near = 0.5;
      const far = 200.0;
      final projection = Matrix4.zero()..setAsPerspective(60, 1.5, near, far);
      final tanHalf = tan(30 * degrees2Radians);

      for (final distance in [near, far]) {
        final expected = distance == near ? 0.0 : 1.0;
        // Center and the four corners of the plane at that distance.
        final halfHeight = distance * tanHalf;
        final halfWidth = halfHeight * 1.5;
        for (final (sx, sy) in [(0, 0), (-1, -1), (1, -1), (1, 1), (-1, 1)]) {
          final point = Vector3(sx * halfWidth, sy * halfHeight, -distance);
          expect(_depthOf(projection, point), closeTo(expected, 1e-6));
          expect(_ndcOf(projection, point).x, closeTo(sx.toDouble(), 1e-6));
          expect(_ndcOf(projection, point).y, closeTo(sy.toDouble(), 1e-6));
        }
      }
      // Depth grows monotonically between them.
      expect(
        _depthOf(projection, Vector3(0, 0, -1)),
        allOf(greaterThan(0), lessThan(1)),
      );
    });

    test('setAsOrthographic maps near to 0, far to 1, linearly between', () {
      final projection = Matrix4.zero()..setAsOrthographic(10, 2, 1, 101);

      expect(_depthOf(projection, Vector3(0, 0, -1)), closeTo(0, 1e-7));
      expect(_depthOf(projection, Vector3(3, 4, -51)), closeTo(0.5, 1e-7));
      expect(_depthOf(projection, Vector3(-3, -4, -101)), closeTo(1, 1e-7));
      // The height is the full vertical extent, the width height * aspect.
      expect(
        _ndcOf(projection, Vector3(10, 5, -50)),
        closeToVector(Vector2(1, 1), 1e-6),
      );
      expect(
        _ndcOf(projection, Vector3(-10, -5, -50)),
        closeToVector(Vector2(-1, -1), 1e-6),
      );
    });

    test('setAsOrthographic accepts a negative near distance', () {
      final projection = Matrix4.zero()..setAsOrthographic(10, 1, -50, 50);

      expect(_depthOf(projection, Vector3(0, 0, 50)), closeTo(0, 1e-7));
      expect(_depthOf(projection, Vector3(0, 0, 0)), closeTo(0.5, 1e-7));
      expect(_depthOf(projection, Vector3(0, 0, -50)), closeTo(1, 1e-7));
    });

    test('setAsOrthographicOffCenter maps the box to the clip volume', () {
      final projection = Matrix4.zero()
        ..setAsOrthographicOffCenter(2, 6, -1, 3, 0, 10);

      expect(
        _ndcOf(projection, Vector3(2, -1, -5)),
        closeToVector(Vector2(-1, -1), 1e-6),
      );
      expect(
        _ndcOf(projection, Vector3(6, 3, -5)),
        closeToVector(Vector2(1, 1), 1e-6),
      );
      expect(
        _ndcOf(projection, Vector3(4, 1, -5)),
        closeToVector(Vector2(0, 0), 1e-6),
      );
      expect(_depthOf(projection, Vector3(4, 1, 0)), closeTo(0, 1e-7));
      expect(_depthOf(projection, Vector3(4, 1, -10)), closeTo(1, 1e-7));
    });

    test('setAsViewMatrix matches vector_math for regular input', () {
      final position = Vector3(3, 4, 5);
      final target = Vector3(-1, 0.5, 2);
      final up = Vector3(0.1, 2, 0);

      final ours = Matrix4.zero()..setAsViewMatrix(position, target, up);
      final reference = Matrix4.zero();
      setViewMatrix(reference, position, target, up);

      expect(ours, closeToMatrix4(reference, 1e-6));
    });

    test('setAsViewMatrix stays a rigid transform for degenerate input', () {
      final cases = [
        // Looking straight down with +y up.
        (Vector3(0, 10, 0), Vector3.zero(), Vector3(0, 1, 0)),
        // Looking straight up.
        (Vector3(0, -10, 0), Vector3.zero(), Vector3(0, 1, 0)),
        // Up along the view direction on the z axis.
        (Vector3(0, 0, 5), Vector3.zero(), Vector3(0, 0, 1)),
        // Zero up vector.
        (Vector3(1, 2, 3), Vector3.zero(), Vector3.zero()),
        // Eye on the target.
        (Vector3(1, 2, 3), Vector3(1, 2, 3), Vector3(0, 1, 0)),
      ];
      for (final (position, target, up) in cases) {
        final view = Matrix4.zero()..setAsViewMatrix(position, target, up);

        expect(view.storage.every((v) => v.isFinite), isTrue);
        expect(view.getRotation().determinant(), closeTo(1, 1e-6));
        // The eye maps to the view-space origin.
        expect(
          view.transformed3(position),
          closeToVector3(Vector3.zero(), 1e-5),
        );
      }

      // Looking down from above, -z is up on screen.
      final view = Matrix4.zero()
        ..setAsViewMatrix(Vector3(0, 10, 0), Vector3.zero(), Vector3(0, 1, 0));
      expect(
        view.transformed3(Vector3(0, 0, -1))
          ..sub(view.transformed3(Vector3.zero())),
        closeToVector3(Vector3(0, 1, 0), 1e-6),
      );
    });
  });

  group('FrustumExtension', () {
    test('setFromViewProjection puts the near plane at depth 0', () {
      final projection = Matrix4.zero()..setAsOrthographic(10, 1, 1, 101);
      final frustum = Frustum()..setFromViewProjection(projection);

      expect(frustum.containsVector3(Vector3(0, 0, -1.01)), isTrue);
      expect(frustum.containsVector3(Vector3(0, 0, -100.99)), isTrue);
      expect(frustum.containsVector3(Vector3(0, 0, -0.99)), isFalse);
      expect(frustum.containsVector3(Vector3(0, 0, -101.01)), isFalse);
      expect(frustum.containsVector3(Vector3(5.01, 0, -50)), isFalse);
      expect(frustum.containsVector3(Vector3(0, -5.01, -50)), isFalse);

      // vector_math's GL extraction would put the near plane at depth -1,
      // 1 unit behind the eye.
      final gl = Frustum()..setFromMatrix(projection);
      expect(gl.containsVector3(Vector3(0, 0, 50)), isTrue);
      expect(frustum.containsVector3(Vector3(0, 0, 50)), isFalse);
    });

    test('a degenerate plane keeps every point', () {
      // Flattens depth: the near plane's normal vanishes.
      final projection = Matrix4.identity()..setEntry(2, 2, 0);
      final frustum = Frustum()..setFromViewProjection(projection);

      expect(frustum.plane5.normal, Vector3.zero());
      expect(frustum.containsVector3(Vector3(0.5, 0.5, 123)), isTrue);
      expect(frustum.containsVector3(Vector3(1.5, 0, 0)), isFalse);
    });
  });

  group('Aabb3Extension.frustumCullTest', () {
    test('classifies boxes against a zero-to-one frustum', () {
      final projection = Matrix4.zero()..setAsOrthographic(10, 1, 1, 101);
      final frustum = Frustum()..setFromViewProjection(projection);

      Aabb3 box(double z) =>
          Aabb3.centerAndHalfExtents(Vector3(0, 0, z), Vector3.all(0.5));

      expect(box(-50).frustumCullTest(frustum), CullResult.inside);
      expect(box(-1.2).frustumCullTest(frustum), CullResult.intersecting);
      expect(box(-100.8).frustumCullTest(frustum), CullResult.intersecting);
      expect(box(0).frustumCullTest(frustum), CullResult.outside);
      expect(box(-102).frustumCullTest(frustum), CullResult.outside);
    });
  });
}
