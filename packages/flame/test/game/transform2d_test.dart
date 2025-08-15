import 'dart:math' as math;

// TODO(spydon): Remove this import once Flutter 3.35.0 is the minimum version.
// ignore: unnecessary_import
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:flame/src/game/transform2d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';
// ignore: unnecessary_import
import 'package:vector_math/vector_math.dart';

void main() {
  // Implementation of statistical error propagation based on
  // Tellinghuisen, J. (2001). Statistical Error Propagation.
  // https://pubs.acs.org/doi/10.1021/jp003484u
  // Note: this function is only applicable to the globalToLocal 2D transform
  // round trip.
  double transform2dRoundTripUncertainty(
    Transform2D transform,
    Vector2 point,
  ) {
    final m = transform.transformMatrix.storage;
    // Calculate the determinant
    final det = m[0] * m[5] - m[1] * m[4];

    // Base uncertainty
    const epsilon = 1 / (1 << 23);

    // Calculate indicative condition number
    final matrixNorm = math.sqrt(
      m[0] * m[0] + m[1] * m[1] + m[4] * m[4] + m[5] * m[5],
    );

    double conditionFactor;
    if (det.abs() > 1e-10) {
      // Calculate condition number
      final invMatrixNorm =
          math.sqrt(m[5] * m[5] + m[1] * m[1] + m[4] * m[4] + m[0] * m[0]) /
          det.abs();
      conditionFactor = matrixNorm * invMatrixNorm;
    } else {
      // For ~singular matrices, small input change -> large output change
      conditionFactor = 1e6;
    }

    // Statistical error propagation
    // There are 8 variables (point + matrix elements)
    const double numVariables = 8;
    // In the round trip there's approx 14 ops
    const double numOperations = 14;

    // Standard deviation (1-σ)
    final sigma =
        epsilon *
        math.sqrt(numVariables) *
        math.sqrt(numOperations) *
        conditionFactor;

    // 99.7 CI + small low-value tolerance
    final tolerance = 3 * sigma + epsilon;

    // Adjust for relative precision
    final magnitude = math.max(1.0, math.max(point.x.abs(), point.y.abs()));

    return tolerance * magnitude;
  }

  group('Transform2D', () {
    test('basic construction', () {
      final t = Transform2D()
        ..position = Vector2(3, 6)
        ..scale = Vector2(2, 0.5)
        ..angle = 1
        ..offset = Vector2(-1, -10);
      expect(t.position, Vector2(3, 6));
      expect(t.scale, Vector2(2, 0.5));
      expect(t.angle, 1);
      expect(t.offset, Vector2(-1, -10));
    });

    test('listenable .position', () {
      final t = Transform2D();
      var notified = 0;
      t.position.addListener(() {
        notified++;
      });

      final zero = Vector2.zero();
      expect(t.localToGlobal(zero), zero);

      t.position.setValues(5, 11);
      expect(t.position, Vector2(5, 11));
      expect(t.localToGlobal(zero), Vector2(5, 11));
      expect(notified, 1);

      t.x = 19;
      expect(t.position, Vector2(19, 11));
      expect(t.localToGlobal(zero), Vector2(19, 11));
      expect(notified, 2);

      t.y = 0;
      expect(t.position, Vector2(19, 0));
      expect(notified, 3);

      t.position.setFrom(Vector2(7, 2.2));
      expect(t.x, closeTo(7, toleranceFloat32(7)));
      expect(t.y, closeTo(2.2, toleranceFloat32(2.2)));
      expect(notified, 4);

      t.position.setZero();
      expect(t.position, zero);
      expect(t.localToGlobal(zero), zero);
      expect(notified, 5);
    });

    test('listenable .scale', () {
      final t = Transform2D();
      var notified = 0;
      t.scale.addListener(() {
        notified++;
      });

      final one = Vector2.all(1);
      expect(t.localToGlobal(one), one);

      t.scale.setValues(2, 3);
      expect(t.scale, Vector2(2, 3));
      expect(t.localToGlobal(one), Vector2(2, 3));
      expect(notified, 1);

      t.scale.setFrom(Vector2(-1, 3));
      expect(t.localToGlobal(one), Vector2(-1, 3));
      expect(notified, 2);

      t.scale.multiply(Vector2.all(3));
      expect(t.scale, Vector2(-3, 9));
      expect(t.localToGlobal(one), Vector2(-3, 9));
      expect(notified, 3);
    });

    test('offset', () {
      final t = Transform2D();
      t.position = Vector2(5, 5);
      t.scale = Vector2(2, 10);
      t.offset = Vector2(1, 0);
      t.angleDegrees = 90;
      // offset of 1 in X direction becomes 2 units because of scale,
      // and changes into Y direction because of rotation:
      expect(t.localToGlobal(Vector2.zero()), Vector2(5, 7));
    });

    test('angle', () {
      final t = Transform2D();
      t.angle = tau / 6;
      expect(t.angleDegrees, closeTo(60, 1e-10));
      t.angleDegrees = 45;
      expect(t.angle, closeTo(tau / 8, 1e-10));
      t.angle = 1;
      expect(t.angle, 1);
      expect(t.angleDegrees, closeTo(360 / tau, 1e-10));
    });

    test('.closeTo', () {
      final t1 = Transform2D();
      final t2 = Transform2D()..angleDegrees = 359;
      expect(t1.closeTo(t2, tolerance: 0.02), true);
      expect(t1.closeTo(t2, tolerance: 0.01), false);
      t1.angle += 17.2855;
      t2.angle += 17.2857;
      expect(t1.closeTo(t2, tolerance: 0.02), true);
      expect(t1.closeTo(t2, tolerance: 0.01), false);
    });

    test('.copy', () {
      final t1 = Transform2D()
        ..position.setValues(3, 11)
        ..scale.setValues(2.4, 5.6)
        ..offset.setValues(-4, 19)
        ..angle = 4;
      final t2 = Transform2D.copy(t1);
      t1.position.setValues(4, 7);
      t1.scale.setValues(2, 0);
      t1.offset.setZero();
      t1.angle = -1;
      // Now check that t2 didn't change
      expect(t2.position, Vector2(3, 11));
      expect(t2.scale, Vector2(2.4, 5.6));
      expect(t2.offset, Vector2(-4, 19));
      expect(t2.angle, 4);
    });

    test('flips', () {
      final t = Transform2D();
      final one = Vector2.all(1);
      expect(t.localToGlobal(one), one);
      t.flipHorizontally();
      expect(t.localToGlobal(one), Vector2(-1, 1));
      t.flipVertically();
      expect(t.localToGlobal(one), Vector2(-1, -1));
      t.flipHorizontally();
      expect(t.localToGlobal(one), Vector2(1, -1));
      t.flipVertically();
      expect(t.localToGlobal(one), Vector2(1, 1));
    });

    testRandom('random', (math.Random rnd) {
      for (var i = 0; i < 20; i++) {
        final translation = Vector2(
          rnd.nextDouble() * 10,
          rnd.nextDouble() * 10,
        );
        final rotation = rnd.nextDouble() * 10;
        final scale = Vector2(
          (rnd.nextDouble() - 0.3) * 3,
          (rnd.nextDouble() - 0.2) * 3,
        );
        final offset = Vector2(
          (rnd.nextDouble() - 0.5) * 10,
          (rnd.nextDouble() - 0.5) * 10,
        );
        final transform2d = Transform2D()
          ..position = translation
          ..angle = rotation
          ..scale = scale
          ..offset = offset;
        final matrix4 = Matrix4.identity()
          ..translateByDouble(translation.x, translation.y, 0.0, 1.0)
          ..rotateZ(rotation)
          ..scaleByDouble(scale.x, scale.y, 1.0, 1.0)
          ..translateByDouble(offset.x, offset.y, 0.0, 1.0);

        for (var k = 0; k < 16; k++) {
          expect(
            transform2d.transformMatrix.storage[k],
            closeTo(
              matrix4.storage[k],
              toleranceVector2Float32(translation) +
                  toleranceFloat32(rotation) +
                  toleranceVector2Float32(scale) +
                  toleranceVector2Float32(offset),
            ),
          );
        }
        // Check round-trip conversion between local and global
        final point1 = Vector2(
          (rnd.nextDouble() - 0.5) * 5,
          (rnd.nextDouble() - 0.5) * 5,
        );
        final point2 = transform2d.globalToLocal(
          transform2d.localToGlobal(point1),
        );

        final tolerance = transform2dRoundTripUncertainty(transform2d, point1);
        expect(
          point1,
          closeToVector(
            point2,
            tolerance,
          ),
        );
      }
    });

    test('degenerate transform', () {
      final t = Transform2D();
      t.scale = Vector2(1, 0);
      final point = Vector2.all(1);
      expect(t.localToGlobal(point), Vector2(1, 0));
      expect(t.globalToLocal(point), Vector2(0, 0));

      t.angleDegrees = 60;
      expect(t.localToGlobal(point).x, closeTo(1 / 2, toleranceFloat32(1 / 2)));
      expect(
        t.localToGlobal(point).y,
        closeTo(math.sqrt(3) / 2, toleranceFloat32(math.sqrt(3) / 2)),
      );
      expect(t.globalToLocal(point), Vector2(0, 0));

      t.scale = Vector2(0, 1);
      expect(t.globalToLocal(point), Vector2(0, 0));
    });
  });
}
