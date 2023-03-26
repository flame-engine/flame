import 'dart:math' as math;
import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('Vector2Extension', () {
    testRandom('Converting a vector to an offset matches x/dx and y/dy',
        (Random r) {
      final vector = Vector2(r.nextDouble(), r.nextDouble());
      final offset = vector.toOffset();
      expectDouble(offset.dx, vector.x, reason: 'dx and x are not matching');
      expectDouble(offset.dy, vector.y, reason: 'dy and y are not matching');
    });

    testRandom('Converting a vector to a Size matches x/width and y/height',
        (Random r) {
      final vector = Vector2(r.nextDouble(), r.nextDouble());
      final size = vector.toSize();
      expectDouble(
        size.width,
        vector.x,
        reason: 'width and x are not matching',
      );
      expectDouble(
        size.height,
        vector.y,
        reason: 'height and y are not matching',
      );
    });

    testRandom('Converting a vector to a Point matches x/x and y/y',
        (Random r) {
      final vector = Vector2(r.nextDouble(), r.nextDouble());
      final point = vector.toPoint();
      expectDouble(
        point.x.toDouble(),
        vector.x,
        reason: 'x and x are not matching',
      );
      expectDouble(
        point.y.toDouble(),
        vector.y,
        reason: 'x and y are not matching',
      );
    });

    testRandom('& on two vectors calls toPositionedRect', (Random r) {
      final v1 = Vector2(r.nextDouble(), r.nextDouble());
      final v2 = Vector2(r.nextDouble(), r.nextDouble());
      final actual = v1 & v2;
      final expected = v1.clone().toPositionedRect(v2.clone());
      expect(actual.top, expected.top);
      expect(actual.bottom, expected.bottom);
      expect(actual.left, expected.left);
      expect(actual.right, expected.right);
    });

    testRandom('toPositionedRect creates a rect with correct coordinates',
        (Random r) {
      final v1 = Vector2(r.nextDouble(), r.nextDouble());
      final size = Vector2(r.nextDouble(), r.nextDouble());
      final rect = v1.toPositionedRect(size);
      expectDouble(rect.left, v1.x, reason: 'rect left should be vector x');
      expectDouble(rect.top, v1.y, reason: 'rect top should be vector y');
      expectDouble(rect.width, size.x, reason: 'rect width should be size x');
      expectDouble(rect.height, size.y, reason: 'rect height should be size y');
    });

    testRandom('toRect creates a rect with correct coordinates', (Random r) {
      final v1 = Vector2(r.nextDouble(), r.nextDouble());
      final rect = v1.toRect();
      expectDouble(rect.left, 0, reason: 'rect left should be 0');
      expectDouble(rect.top, 0, reason: 'rect top should be 0');
      expectDouble(rect.width, v1.x, reason: 'rect width should be vector x');
      expectDouble(
        rect.height,
        v1.y,
        reason: 'rect height should be vector y',
      );
    });

    testRandom('lerp interpolates the vector the right way', (Random r) {
      final v1 = Vector2(r.nextDouble(), r.nextDouble());
      final to = Vector2(r.nextDouble(), r.nextDouble());
      final t = r.nextDouble();

      final v1Clone = v1.clone()..lerp(to, t);

      // setFrom(this + (to - this) * t)
      expectDouble(v1Clone.x, v1.x + (to.x - v1.x) * t);
      expectDouble(v1Clone.y, v1.y + (to.y - v1.y) * t);
    });

    testRandom('isZero returns true with 0 and false otherwise', (Random r) {
      final vZero = Vector2(0, 0);
      final vZeroY = Vector2(1, 0);
      final vZeroX = Vector2(0, 1);
      final vNotZero = Vector2(r.nextDouble() + 1, r.nextDouble() + 1);

      expect(vZero.isZero(), true, reason: '(0,0) is Zero');
      expect(vZeroX.isZero(), false, reason: '(1,0) is not zero');
      expect(vZeroY.isZero(), false, reason: '(0,1) is not zero');
      expect(vNotZero.isZero(), false, reason: '(x,x) is not zero');
    });

    testRandom('isIdentity returns true with 1,1 and false otherwise',
        (Random r) {
      // nextDouble is never 1
      final vIdentity = Vector2(1, 1);
      final vIdentityX = Vector2(1, r.nextDouble());
      final vIdentityY = Vector2(r.nextDouble(), 1);
      final vNotIdentity = Vector2(r.nextDouble(), r.nextDouble());

      expect(vIdentity.isIdentity(), true, reason: '(1,1) is isIdentity');
      expect(vIdentityX.isIdentity(), false, reason: '(1,x) is not isIdentity');
      expect(vIdentityY.isIdentity(), false, reason: '(x,1) is not isIdentity');
      expect(
        vNotIdentity.isIdentity(),
        false,
        reason: '(x,x) is not isIdentity',
      );
    });

    testRandom('taxicabDistanceTo', (Random r) {
      final origin = Vector2(r.nextDouble(), r.nextDouble());
      final destination = Vector2(r.nextDouble(), r.nextDouble());

      expect(
        origin.taxicabDistanceTo(destination),
        destination.taxicabDistanceTo(origin),
      );
      expect(
        origin.taxicabDistanceTo(destination),
        (origin.x - destination.x).abs() + (origin.y - destination.y).abs(),
      );
    });

    group('Rotation', () {
      test('test rotate', () {
        final p = Vector2(1.0, 0.0)..rotate(math.pi / 2);
        expectDouble(p.x, 0.0);
        expectDouble(p.y, 1.0);
      });

      test('rotate - no center defined', () {
        final position = Vector2(0.0, 1.0);
        position.rotate(-math.pi / 2);
        expect(position, closeToVector(Vector2(1.0, 0.0)));
      });

      test('rotate - no center defined, negative position', () {
        final position = Vector2(0.0, -1.0);
        position.rotate(-math.pi / 2);
        expect(position, closeToVector(Vector2(-1.0, 0.0)));
      });

      test('rotate - with center defined', () {
        final position = Vector2(0.0, 1.0);
        final center = Vector2(1.0, 1.0);
        position.rotate(-math.pi / 2, center: center);
        expect(position, closeToVector(Vector2(1.0, 2.0)));
      });

      test('rotate - with positive direction', () {
        final position = Vector2(0.0, 1.0);
        final center = Vector2(1.0, 1.0);
        position.rotate(math.pi / 2, center: center);
        expect(position, closeToVector(Vector2(1.0, 0.0)));
      });

      test('rotate - with a negative y position', () {
        final position = Vector2(2.0, -3.0);
        final center = Vector2(1.0, 1.0);
        position.rotate(math.pi / 2, center: center);
        expect(position, closeToVector(Vector2(5.0, 2.0)));
      });

      test('rotate - with a negative x position', () {
        final position = Vector2(-2.0, 3.0);
        final center = Vector2(1.0, 1.0);
        position.rotate(math.pi / 2, center: center);
        expect(position, closeToVector(Vector2(-1.0, -2.0)));
      });

      test('rotate - with a negative position', () {
        final position = Vector2(-2.0, -3.0);
        final center = Vector2(1.0, 0.0);
        position.rotate(math.pi / 2, center: center);
        expect(position, closeToVector(Vector2(4.0, -3.0)));
      });
    });

    group('Scaling', () {
      test('scaleTo', () {
        final p = Vector2(1.0, 0.0)
          ..rotate(math.pi / 4)
          ..scaleTo(2.0);

        expectDouble(p.length, 2.0);

        p.rotate(-math.pi / 4);
        expectDouble(p.length, 2.0);
        expectDouble(p.x, 2.0);
        expectDouble(p.y, 0.0);
      });

      test('scaleTo the zero vector', () {
        final p = Vector2.zero();
        expect(p.normalized().length, 0.0);
      });
    });

    group('clampLength', () {
      test('clamp length min', () {
        final v = Vector2(1, 0)..clampLength(2.0, 3.0);
        expect(v.length, 2.0);
      });

      test('clamp length max', () {
        final v = Vector2(1, 0)..clampLength(0.5, 0.8);
        expect(v.length, 0.8);
      });

      test('clamp negative vector', () {
        final v = Vector2(-1, -1)..clampLength(0.5, 0.8);
        expect(v.length, 0.8);
      });

      test('no effect on vector in range', () {
        final v = Vector2(1, 0)..clampLength(0.5, 2.0);
        expect(v.length, 1.0);
      });
    });

    group('projection', () {
      test('Project onto longer vector', () {
        final u = Vector2(5, 2);
        final v = Vector2(10, 0);
        final result = u.projection(v);
        expect(result, Vector2(5, 0));
      });

      test('Project onto shorter vector', () {
        final u = Vector2(5, 2);
        final v = Vector2(2, 0);
        final result = u.projection(v);
        expect(result, Vector2(5, 0));
      });

      test('Project onto vector in other direction', () {
        final u = Vector2(5, 2);
        final v = Vector2(-10, 0);
        final result = u.projection(v);
        expect(result, Vector2(5, 0));
      });

      test('Project onto vector with out', () {
        final out = Vector2.zero();
        final u = Vector2(5, 2);
        final v = Vector2(-10, 0);
        final result = u.projection(v, out: out);
        expect(result, Vector2(5, 0));
        expect(out, Vector2(5, 0));
      });

      test('Project onto vector with out as sane return and argument', () {
        var out = Vector2.zero();
        final u = Vector2(5, 2);
        final v = Vector2(-10, 0);
        out = u.projection(v, out: out);
        expect(out, Vector2(5, 0));
      });
    });

    group('inversion', () {
      test('invert', () {
        final v = Vector2.all(1);
        v.invert();
        expect(v, Vector2.all(-1));
      });

      test('inverted', () {
        final v = Vector2.all(1);
        final w = v.inverted();
        expect(v, Vector2.all(1));
        expect(w, Vector2.all(-1));
      });
    });

    group('inversion', () {
      test('invert', () {
        final v = Vector2.all(1);
        v.invert();
        expect(v, Vector2.all(-1));
      });

      test('inverted', () {
        final v = Vector2.all(1);
        final w = v.inverted();
        expect(v, Vector2.all(1));
        expect(w, Vector2.all(-1));
      });
    });

    group('Moving', () {
      test('moveToTarget - fully horizontal', () {
        final current = Vector2(10.0, 0.0);
        final target = Vector2(20.0, 0.0);

        current.moveToTarget(target, 0);
        expect(current, Vector2(10.0, 0.0));

        current.moveToTarget(target, 1);
        expect(current, Vector2(11.0, 0.0));

        current.moveToTarget(target, 6);
        expect(current, Vector2(17.0, 0.0));

        current.moveToTarget(target, 5);
        expect(current, Vector2(20.0, 0.0));
      });

      test('moveToTarget - fully vertical', () {
        final current = Vector2(10.0, 0.0);
        final target = Vector2(10.0, 100.0);

        current.moveToTarget(target, 0);
        expect(current, Vector2(10.0, 0.0));

        current.moveToTarget(target, 1);
        expect(current, Vector2(10.0, 1.0));

        current.moveToTarget(target, 80);
        expect(current, Vector2(10.0, 81.0));

        current.moveToTarget(target, 19);
        expect(current, Vector2(10.0, 100.0));
      });

      test('moveToTarget - arbitrary direction', () {
        final current = Vector2(2.0, 2.0);
        final target = Vector2(4.0, 6.0); // direction is 1,2

        current.moveToTarget(target, 0);
        expect(current, Vector2(2.0, 2.0));

        current.moveToTarget(target, math.sqrt(5));
        expect(current, Vector2(3.0, 4.0));

        current.moveToTarget(target, math.sqrt(5));
        expect(current, Vector2(4.0, 6.0));
      });
    });

    test('screenAngle', () {
      // Up
      final position = Vector2(0.0, -1.0);
      expectDouble(position.screenAngle(), 0.0);
      // Down
      position.setValues(0.0, 1.0);
      expectDouble(position.screenAngle().abs(), math.pi);
      // Left
      position.setValues(-1.0, 0.0);
      expectDouble(position.screenAngle(), -math.pi / 2);
      // Right
      position.setValues(1.0, 0.0);
      expectDouble(position.screenAngle(), math.pi / 2);
    });

    testRandom('% created a new vector with modulo a second one', (Random r) {
      final x = r.nextDouble();
      final modX = r.nextDouble();
      final y = r.nextDouble();
      final modY = r.nextDouble();
      final actual = Vector2(x, y) % Vector2(modX, modY);
      expectDouble(actual.x, x % modX);
      expectDouble(actual.y, y % modY);
    });

    testRandom('fromInts created a vector with x y', (Random r) {
      var x = r.nextInt(1 << 32);
      var y = r.nextInt(1 << 32);
      var vector = Vector2Extension.fromInts(x, y);
      expectDouble(vector.x, x.toDouble());
      expectDouble(vector.y, y.toDouble());

      x = -r.nextInt(1 << 32);
      y = -r.nextInt(1 << 32);
      vector = Vector2Extension.fromInts(x, y);
      expectDouble(vector.x, x.toDouble());
      expectDouble(vector.y, y.toDouble());
    });

    test('identity() creator is identity', () {
      final identity = Vector2Extension.identity();
      expect(identity.isIdentity(), true);
      expect(identity.x, 1);
      expect(identity.y, 1);
    });

    // Following are tests of code not implemented by flame

    testRandom('Adding two vectors adds their x and their y', (Random r) {
      final v1 = Vector2(r.nextDouble(), r.nextDouble());
      final v2 = Vector2(r.nextDouble(), r.nextDouble());
      final actual = v1 + v2;
      expectDouble(
        actual.x,
        v1.x + v2.x,
        reason: "Vector addition's 'x' is not working",
      );
      expectDouble(
        actual.y,
        v1.y + v2.y,
        reason: "Vector addition's 'y' is not working",
      );
    });

    testRandom('Cloning a vector gives a vector with the exact same x and y',
        (Random r) {
      final original = Vector2(r.nextDouble(), r.nextDouble());
      final clone = original.clone();

      expectDouble(
        clone.x,
        original.x,
        reason: "Clone's x should be original's x",
      );
      expectDouble(
        clone.y,
        original.y,
        reason: "Clone's y should be original's y",
      );
    });

    test('test length', () {
      final p1 = Vector2(3.0, 4.0);
      expectDouble(p1.length, 5.0);

      final p2 = Vector2(2.0, 0.0);
      expectDouble(p2.length, 2.0);

      final p3 = Vector2(0.0, 1.5);
      expectDouble(p3.length, 1.5);
    });

    test('test distance', () {
      final p1 = Vector2(10.0, 20.0);
      final p2 = Vector2(13.0, 24.0);
      final result = p1.distanceTo(p2);
      expectDouble(result, 5.0);
    });

    test('equality', () {
      final p1 = Vector2.zero();
      final p2 = Vector2.zero();
      expect(p1 == p2, true);
    });

    test('non equality', () {
      final p1 = Vector2.zero();
      final p2 = Vector2(1.0, 0.0);
      expect(p1 == p2, false);
    });

    test('hashCode', () {
      final p1 = Vector2(2.0, -1.0);
      final p2 = Vector2(1.0, 0.0);
      expect(p1.hashCode == p2.hashCode, false);
    });

    test('limit', () {
      final p1 = Vector2(1.0, 0.0);
      p1.clampScalar(0, 0.75);
      expect(p1.length, 0.75);
      expect(p1.x, 0.75);
      expect(p1.y, 0.0);

      final p2 = Vector2(1.0, 1.0);
      p2.clampScalar(0, 3.0);
      expectDouble(p2.length, math.sqrt(2));
      expect(p2.x, 1.0);
      expect(p2.y, 1.0);
      p2.clampScalar(0, 1.0);
      expectDouble(p2.length, math.sqrt(2));
      expect(p2.x, p2.y);
    });
  });

  testRandom('Creating a Vector2 fromRadians points to the correct direction',
      (Random r) {
    // See more on https://en.wikipedia.org/wiki/Rotation_matrix
    // TL;DR;
    // (x', y') = (x cos(p) - y sin(p) , x sin(p) + y cos(p))
    // Our x is 0 and y -1
    // (x', y') = (0 - -sin(p), 0 + -cos(p))
    // (x', y') = (sin(p),-cos(p))

    var angleInRadians = r.nextDouble() * 2 * math.pi;
    var pointingVector = Vector2Extension.fromRadians(angleInRadians);

    expectDouble(pointingVector.x, math.sin(angleInRadians));
    // Base Vector2 is (0, -1)
    expectDouble(pointingVector.y, -math.cos(angleInRadians));

    // Same with negative Radians
    angleInRadians = -r.nextDouble() * 2 * math.pi;
    pointingVector = Vector2Extension.fromRadians(angleInRadians);
    expectDouble(pointingVector.x, math.sin(angleInRadians));
    expectDouble(pointingVector.y, -math.cos(angleInRadians));
  });

  testRandom('Creating a Vector2 fromDegrees points to the correct direction',
      (Random r) {
    // See more on https://en.wikipedia.org/wiki/Rotation_matrix
    // TL;DR;
    // (x', y') = (x cos(p) - y sin(p) , x sin(p) + y cos(p))
    // Our x is 0 and y -1
    // (x', y') = (0 - -sin(p), 0 + -cos(p))
    // (x', y') = (sin(p),-cos(p))

    var angleInDegrees = r.nextDouble() * 360;
    var pointingVector = Vector2Extension.fromDegrees(angleInDegrees);

    var angleInRadians = angleInDegrees * math.pi / 180;
    expectDouble(pointingVector.x, math.sin(angleInRadians));
    expectDouble(pointingVector.y, -math.cos(angleInRadians));

    // Same with negative Degrees
    angleInDegrees = -r.nextDouble() * 360;
    pointingVector = Vector2Extension.fromDegrees(angleInDegrees);

    angleInRadians = angleInDegrees * math.pi / 180;
    expectDouble(pointingVector.x, math.sin(angleInRadians));
    expectDouble(pointingVector.y, -math.cos(angleInRadians));
  });
}
