import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flame/particles.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EmitterShape', () {
    test('PointEmitterShape always samples the origin', () {
      final random = Random(42);
      final out = Vector2.all(99);
      const PointEmitterShape().samplePosition(random, out);
      expect(out, Vector2.zero());
    });

    test('CircleEmitterShape samples inside the circle', () {
      final random = Random(42);
      const shape = CircleEmitterShape(10);
      final out = Vector2.zero();
      for (var i = 0; i < 100; i++) {
        shape.samplePosition(random, out);
        expect(out.length, lessThanOrEqualTo(10));
      }
    });

    test('CircleEmitterShape with edgeOnly samples on the edge', () {
      final random = Random(42);
      const shape = CircleEmitterShape(10, edgeOnly: true);
      final out = Vector2.zero();
      for (var i = 0; i < 100; i++) {
        shape.samplePosition(random, out);
        expect(out.length, closeTo(10, 1e-6));
      }
    });

    test('RectangleEmitterShape samples inside the centered rectangle', () {
      final random = Random(42);
      const shape = RectangleEmitterShape(20, 10);
      final out = Vector2.zero();
      for (var i = 0; i < 100; i++) {
        shape.samplePosition(random, out);
        expect(out.x.abs(), lessThanOrEqualTo(10));
        expect(out.y.abs(), lessThanOrEqualTo(5));
      }
    });
  });
}
