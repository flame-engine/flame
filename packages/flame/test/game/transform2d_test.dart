import 'dart:math' as math;

import 'package:flame/src/game/transform2d.dart';
import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
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
      expect(t.x, 7);
      expect(t.y, 2.2);
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
      const tau = Transform2D.tau;
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

    test('random', () {
      final rnd = math.Random();
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
          ..translate(translation.x, translation.y)
          ..rotateZ(rotation)
          ..scale(scale.x, scale.y, 1)
          ..translate(offset.x, offset.y);
        for (var k = 0; k < 16; k++) {
          expect(
            transform2d.transformMatrix.storage[k],
            closeTo(matrix4.storage[k], 1e-10),
          );
        }
        // Check that converting between local and global is round-trippable
        final point1 =
            Vector2((rnd.nextDouble() - 0.5) * 5, (rnd.nextDouble() - 0.5) * 5);
        final point2 =
            transform2d.globalToLocal(transform2d.localToGlobal(point1));
        expect(point1.x, closeTo(point2.x, 1e-10));
        expect(point1.y, closeTo(point2.y, 1e-10));
      }
    });

    test('degenerate transform', () {
      final t = Transform2D();
      t.scale = Vector2(1, 0);
      final point = Vector2.all(1);
      expect(t.localToGlobal(point), Vector2(1, 0));
      expect(t.globalToLocal(point), Vector2(0, 0));

      t.angleDegrees = 60;
      expect(t.localToGlobal(point).x, closeTo(1 / 2, 1e-10));
      expect(t.localToGlobal(point).y, closeTo(math.sqrt(3) / 2, 1e-10));
      expect(t.globalToLocal(point), Vector2(0, 0));

      t.scale = Vector2(0, 1);
      expect(t.globalToLocal(point), Vector2(0, 0));
    });
  });
}
