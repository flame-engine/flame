import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('Aabb2Extension', () {
    // aabb2 is an axis aligned bounding box between a min and a max
    // see https://api.flutter.dev/flutter/vector_math_64/Aabb2-class.html
    // The extension is used to convert this bounding box to a rect.
    test('Default aabb constructor', () {
      final aab2 = Aabb2();
      // With this constructor, min and max are set to the origin (0,0)
      // So the corresponding rect should be (0,0,0,0)
      final aab2Rect = aab2.toRect();
      _checkRectValues(
        aab2Rect,
        left: 0,
        top: 0,
        right: 0,
        bottom: 0,
      );
    });

    testRandom('centerAndHalfExtents constructor', (Random r) {
      // This constructor is useful in circles (see lib/src/experimental/geometry/shapes/circle.dart)
      final center = Vector2(r.nextDouble(), r.nextDouble());
      final halfExtends = Vector2(r.nextDouble(), r.nextDouble());

      final aab2 = Aabb2.centerAndHalfExtents(center, halfExtends);
      final aab2Rect = aab2.toRect();

      _checkRectValues(
        aab2Rect,
        left: aab2.min.x,
        top: aab2.min.y,
        right: aab2.max.x,
        bottom: aab2.max.y,
      );
    });

    testRandom('aabb minMax constructor', (Random r) {
      final min = Vector2(r.nextDouble(), r.nextDouble());
      final max = Vector2(r.nextDouble(), r.nextDouble());

      final aab2 = Aabb2.minMax(min, max);
      final aab2Rect = aab2.toRect();

      _checkRectValues(
        aab2Rect,
        left: min.x,
        top: min.y,
        right: max.x,
        bottom: max.y,
      );
    });
  });
}

void _checkRectValues(
  Rect rect, {
  required double left,
  required double top,
  required double right,
  required double bottom,
}) {
  expect(rect.left, left, reason: 'left does not match');
  expect(rect.top, top, reason: 'top does not match');
  expect(rect.right, right, reason: 'right does not match');
  expect(rect.bottom, bottom, reason: 'bottom does not match');
}
