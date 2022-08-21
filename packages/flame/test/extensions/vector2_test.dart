import 'dart:math' as math;

import 'package:flame/extensions.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('Vector2 test', () {
    test('test add', () {
      final p = Vector2(0.0, 5.0) + Vector2(5.0, 5.0);
      expectDouble(p.x, 5.0);
      expectDouble(p.y, 10.0);
    });

    test('test clone', () {
      final p = Vector2(1.0, 0.0);
      final clone = p.clone();

      clone.scale(2.0);
      expectDouble(p.x, 1.0);
      expectDouble(clone.x, 2.0);
    });

    test('test rotate', () {
      final p = Vector2(1.0, 0.0)..rotate(math.pi / 2);
      expectDouble(p.x, 0.0);
      expectDouble(p.y, 1.0);
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

    test('scaleTo', () {
      final p = Vector2(1.0, 0.0)
        ..rotate(math.pi / 4)
        ..scaleTo(2.0);

      expect(p.length, 2.0);

      p.rotate(-math.pi / 4);
      expect(p.length, 2.0);
      expect(p.x, 2.0);
      expect(p.y, 0.0);
    });

    test('scaleTo the zero vector', () {
      final p = Vector2.zero();
      expect(p.normalized().length, 0.0);
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
}
