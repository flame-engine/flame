import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('OffsetExtension', () {
    testRandom('toVector2 has x to offset.dx and y to offset.dy', (Random r) {
      final offset = Offset(r.nextDouble(), r.nextDouble());
      final vector2 = offset.toVector2();

      expect(vector2.x, offset.dx, reason: 'x dx does not match');
      expect(vector2.y, offset.dy, reason: 'y dy does not match');
    });

    testRandom('toSize has width to offset.dx and height to offset.dy',
        (Random r) {
      final offset = Offset(r.nextDouble(), r.nextDouble());
      final size = offset.toSize();

      expect(size.width, offset.dx, reason: 'width dx does not match');
      expect(size.height, offset.dy, reason: 'height dy does not match');
    });

    testRandom('toSize has x to offset.dx and y to offset.dy', (Random r) {
      final offset = Offset(r.nextDouble(), r.nextDouble());
      final point = offset.toPoint();

      expect(point.x, offset.dx, reason: 'x dx does not match');
      expect(point.y, offset.dy, reason: 'y dy does not match');
    });

    testRandom(
        'toRect has left: 0, top: 0, width: offset.dx, height: offset.dy',
        (Random r) {
      final offset = Offset(r.nextDouble(), r.nextDouble());
      final rect = offset.toRect();

      expect(rect.left, 0, reason: 'left should be 0 as init');
      expect(rect.top, 0, reason: 'top should be 0 as init');
      expect(rect.width, offset.dx, reason: 'width dx does not match');
      expect(rect.height, offset.dy, reason: 'height dy does not match');
    });
  });
}
