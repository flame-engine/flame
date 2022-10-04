import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('RectangleExtension', () {
    testRandom('Default rectangle constructor', (Random r) {
      final rectangle = Rectangle(
        r.nextDouble(),
        r.nextDouble(),
        r.nextDouble(),
        r.nextDouble(),
      );
      final rect = rectangle.toRect();
      _checkRectValues(
        rect,
        left: rectangle.left,
        top: rectangle.top,
        right: rectangle.right,
        bottom: rectangle.bottom,
      );
    });

    testRandom('fromPoints rectangle constructor', (Random r) {
      final leftTop = Point(r.nextDouble(), r.nextDouble());
      final rightBottom = Point(r.nextDouble(), r.nextDouble());

      // T left = min(a.x, b.x);
      // T width = (max(a.x, b.x) - left) as T;
      // T top = min(a.y, b.y);
      // T height = (max(a.y, b.y) - top) as T;
      final rectangle = Rectangle.fromPoints(leftTop, rightBottom);
      final rect = rectangle.toRect();
      _checkRectValues(
        rect,
        left: min(leftTop.x, rightBottom.x),
        top: min(leftTop.y, rightBottom.y),
        right: max(leftTop.x, rightBottom.x),
        bottom: max(leftTop.y, rightBottom.y),
      );
    });
  });
}

void _checkRectValues(
  Rect rect, {
  // top left angle x
  required double left,
  // top left angle y
  required double top,
  // bottom right angle's x
  required double right,
  // bottom right angle's y
  required double bottom,
}) {
  expect(rect.left, left, reason: 'left does not match');
  expect(rect.top, top, reason: 'top does not match');
  expect(rect.right, right, reason: 'right does not match');
  expect(rect.bottom, bottom, reason: 'bottom does not match');
}
