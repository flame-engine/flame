import 'dart:math' as math;

import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(ComponentAngle, () {
    test('defaults to no rotation', () {
      expect(ComponentAngle.zero.radians, equals(0));
      expect(ComponentAngle.zero.degrees, equals(0));
    });

    test('supports value equality', () {
      expect(
        const ComponentAngle(radians: 1),
        equals(const ComponentAngle(radians: 1)),
      );
      expect(
        const ComponentAngle(radians: 1),
        isNot(equals(const ComponentAngle(radians: 2))),
      );
    });

    test('converts between degrees and radians', () {
      expect(ComponentAngle.fromDegrees(180).radians, equals(math.pi));
      expect(const ComponentAngle(radians: math.pi / 2).degrees, equals(90));
    });

    test('round-trips through JSON', () {
      const angle = ComponentAngle(radians: 1.5);

      expect(ComponentAngle.fromJson(angle.toJson()), equals(angle));
      expect(angle.toJson(), equals({'radians': 1.5}));
    });

    test('falls back to no rotation for missing or invalid values', () {
      expect(ComponentAngle.fromJson(null), equals(ComponentAngle.zero));
      expect(
        ComponentAngle.fromJson(const <String, dynamic>{}),
        equals(ComponentAngle.zero),
      );
      expect(
        ComponentAngle.fromJson(const {'radians': 'a lot'}),
        equals(ComponentAngle.zero),
      );
    });

    test('accepts integer values', () {
      expect(
        ComponentAngle.fromJson(const {'radians': 2}),
        equals(const ComponentAngle(radians: 2)),
      );
    });

    test('copyWith replaces the given fields', () {
      expect(
        const ComponentAngle(radians: 1).copyWith(radians: 2),
        equals(const ComponentAngle(radians: 2)),
      );
      expect(
        const ComponentAngle(radians: 1).copyWith(),
        equals(const ComponentAngle(radians: 1)),
      );
    });
  });
}
