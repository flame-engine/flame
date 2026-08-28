import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:test/test.dart';

void main() {
  group('VectorValue', () {
    test('constructors', () {
      expect(VectorValue(1, 2).x, 1);
      expect(VectorValue(1, 2).y, 2);
      expect(VectorValue.all(3).equals(VectorValue(3, 3)), isTrue);
      expect(VectorValue.zero.equals(VectorValue(0, 0)), isTrue);
      expect(VectorValue.one.equals(VectorValue(1, 1)), isTrue);
      expect(
        VectorValue.fromVector2(Vector2(4, 5)).equals(VectorValue(4, 5)),
        isTrue,
      );
      expect(
        VectorValue.fromOffset(const Offset(6, 7)).equals(VectorValue(6, 7)),
        isTrue,
      );
      expect(
        VectorValue.fromSize(const Size(8, 9)).equals(VectorValue(8, 9)),
        isTrue,
      );
    });

    test('fromRadians matches Vector2Extension.fromRadians', () {
      for (final angle in [0.0, 0.5, math.pi / 2, math.pi, -1.2, 4.0]) {
        final expected = Vector2Extension.fromRadians(angle);
        final actual = VectorValue.fromRadians(angle);
        expect(actual.x, closeTo(expected.x, 1e-6));
        expect(actual.y, closeTo(expected.y, 1e-6));
      }
    });

    test('keeps double precision', () {
      expect(VectorValue(0.1, 0.2).x, 0.1);
      expect(Vector2(0.1, 0.2).x, isNot(0.1));
    });

    test('withX and withY', () {
      expect(VectorValue(1, 2).withX(5).equals(VectorValue(5, 2)), isTrue);
      expect(VectorValue(1, 2).withY(5).equals(VectorValue(1, 5)), isTrue);
    });

    test('arithmetic operators', () {
      final a = VectorValue(1, 2);
      final b = VectorValue(3, -4);
      expect((a + b).equals(VectorValue(4, -2)), isTrue);
      expect((a - b).equals(VectorValue(-2, 6)), isTrue);
      expect((-a).equals(VectorValue(-1, -2)), isTrue);
      expect((a * 2).equals(VectorValue(2, 4)), isTrue);
      expect((a / 2).equals(VectorValue(0.5, 1)), isTrue);
      expect(a.multiplied(b).equals(VectorValue(3, -8)), isTrue);
      expect(b.divided(a).equals(VectorValue(3, -2)), isTrue);
    });

    test('compound expression', () {
      final size = VectorValue(10, 20);
      final offset = VectorValue(3, 4);
      final velocity = VectorValue(30, -20);
      const dt = 0.5;
      final result = size / 2 + offset + velocity * dt;
      expect(result.equals(VectorValue(5 + 3 + 15, 10 + 4 - 10)), isTrue);
    });

    test('dot, cross, length', () {
      final a = VectorValue(3, 4);
      final b = VectorValue(-4, 3);
      expect(a.dot(b), 0);
      expect(a.dot(a), 25);
      expect(a.cross(b), 25);
      expect(a.length2, 25);
      expect(a.length, 5);
      expect(VectorValue.zero.isZero, isTrue);
      expect(a.isZero, isFalse);
      expect(a.isFinite, isTrue);
      expect(VectorValue(double.nan, 0).isFinite, isFalse);
    });

    test('normalized and withLength', () {
      final a = VectorValue(3, 4);
      expect(a.normalized().closeTo(VectorValue(0.6, 0.8)), isTrue);
      expect(a.withLength(10).closeTo(VectorValue(6, 8)), isTrue);
      expect(a.withLength(-10).closeTo(VectorValue(6, 8)), isTrue);
      expect(VectorValue.zero.normalized().isZero, isTrue);
      expect(VectorValue.zero.withLength(3).isZero, isTrue);
      expect(a.withLengthClamped(1, 2).length, closeTo(2, 1e-9));
      expect(a.withLengthClamped(6, 8).length, closeTo(6, 1e-9));
      expect(a.withLengthClamped(1, 8).length, closeTo(5, 1e-9));
    });

    test('perpendicular, distance, lerp', () {
      expect(
        VectorValue(1, 0).perpendicular().equals(VectorValue(0, 1)),
        isTrue,
      );
      expect(VectorValue(1, 1).distanceTo(VectorValue(4, 5)), 5);
      expect(VectorValue(1, 1).distanceToSquared(VectorValue(4, 5)), 25);
      expect(
        VectorValue(
          0,
          0,
        ).lerp(VectorValue(10, 20), 0.25).equals(VectorValue(2.5, 5)),
        isTrue,
      );
    });

    test('rotated matches Vector2Extension.rotate', () {
      final center = VectorValue(2, -1);
      for (final angle in [0.0, 0.3, math.pi / 2, math.pi, -2.5]) {
        final expected = Vector2(3, 4)..rotate(angle);
        final actual = VectorValue(3, 4).rotated(angle);
        expect(actual.x, closeTo(expected.x, 1e-5));
        expect(actual.y, closeTo(expected.y, 1e-5));

        final expectedAroundCenter = Vector2(3, 4)
          ..rotate(angle, center: center.toVector2());
        final actualAroundCenter = VectorValue(
          3,
          4,
        ).rotated(angle, center: center);
        expect(actualAroundCenter.x, closeTo(expectedAroundCenter.x, 1e-5));
        expect(actualAroundCenter.y, closeTo(expectedAroundCenter.y, 1e-5));
      }
    });

    test('angles', () {
      expect(
        VectorValue(1, 0).angleTo(VectorValue(0, 1)),
        closeTo(math.pi / 2, 1e-9),
      );
      expect(
        VectorValue(1, 0).angleTo(VectorValue(-1, 0)),
        closeTo(math.pi, 1e-9),
      );
      expect(VectorValue(1, 0).angleTo(VectorValue.zero), 0);
      expect(
        VectorValue(1, 0).angleToSigned(VectorValue(0, 1)),
        closeTo(math.pi / 2, 1e-9),
      );
      expect(
        VectorValue(0, 1).angleToSigned(VectorValue(1, 0)),
        closeTo(-math.pi / 2, 1e-9),
      );
      for (final vector in [Vector2(0, -1), Vector2(1, 0), Vector2(-3, 2)]) {
        expect(
          vector.value.screenAngle,
          closeTo(vector.screenAngle(), 1e-6),
        );
      }
    });

    test('component-wise helpers', () {
      final a = VectorValue(-1.5, 2.5);
      final b = VectorValue(1, 1);
      expect(a.abs().equals(VectorValue(1.5, 2.5)), isTrue);
      expect(a.min(b).equals(VectorValue(-1.5, 1)), isTrue);
      expect(a.max(b).equals(VectorValue(1, 2.5)), isTrue);
      expect(
        a
            .clamp(VectorValue(-1, 0), VectorValue(0, 2))
            .equals(VectorValue(-1, 2)),
        isTrue,
      );
      expect(a.floor().equals(VectorValue(-2, 2)), isTrue);
      expect(a.ceil().equals(VectorValue(-1, 3)), isTrue);
      expect(a.round().equals(VectorValue(-2, 3)), isTrue);
    });

    test('equals and closeTo', () {
      expect(VectorValue(1, 2).equals(VectorValue(1, 2)), isTrue);
      expect(VectorValue(1, 2).equals(VectorValue(1, 2.0000001)), isFalse);
      expect(
        VectorValue(1, 2).closeTo(VectorValue(1, 2.0000001), epsilon: 1e-6),
        isTrue,
      );
      expect(VectorValue(1, 2).closeTo(VectorValue(1, 2.1)), isFalse);
    });

    test('conversions', () {
      final v = VectorValue(1.5, -2);
      expect(v.toVector2(), Vector2(1.5, -2));
      expect(v.toOffset(), const Offset(1.5, -2));
      expect(v.toSize(), const Size(1.5, -2));
      expect(v.describe(), 'VectorValue(1.5, -2.0)');
      final target = Vector2.zero();
      v.copyInto(target);
      expect(target, Vector2(1.5, -2));
    });
  });

  group('Vector2Extension.value', () {
    test('reads the current components', () {
      final vector = Vector2(3, 4);
      expect(vector.value.equals(VectorValue(3, 4)), isTrue);
      vector.x = 5;
      expect(vector.value.equals(VectorValue(5, 4)), isTrue);
    });

    test('assigning sets the components', () {
      final vector = Vector2.zero();
      vector.value = VectorValue(1, 2);
      expect(vector, Vector2(1, 2));
      vector.value += VectorValue(1, 1) * 2;
      expect(vector, Vector2(3, 4));
    });

    test('NotifyingVector2 notifies once per assignment', () {
      final vector = NotifyingVector2(1, 1);
      final version = vector.version;
      var notified = 0;
      vector.addListener(() => notified++);
      vector.value =
          vector.value / 2 + VectorValue(3, 4) + VectorValue(30, -20) * 0.5;
      expect(notified, 1);
      expect(vector, Vector2(0.5 + 3 + 15, 0.5 + 4 - 10));
      expect(vector.version, version + 1);
    });

    test('works through a PositionComponent', () {
      final component = PositionComponent(
        position: Vector2(10, 10),
        size: Vector2(4, 6),
      );
      final velocity = VectorValue(2, -1);
      component.position.value += velocity * 0.5;
      expect(component.position, Vector2(11, 9.5));
      component.position.value = component.size.value / 2;
      expect(component.position, Vector2(2, 3));
      expect(component.transformMatrix.storage[12], 2);
    });
  });
}
