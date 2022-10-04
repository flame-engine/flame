import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('SizeExtension', () {
    testRandom('toVector2 has x to size.dx and y to size.dy', (Random r) {
      final size = Size(r.nextDouble(), r.nextDouble());
      final vector2 = size.toVector2();

      expect(vector2.x, size.width, reason: 'x width does not match');
      expect(vector2.y, size.height, reason: 'y height does not match');
    });

    testRandom('toOffset has dx to size.width and dy to size.dy', (Random r) {
      final size = Size(r.nextDouble(), r.nextDouble());
      final offset = size.toOffset();

      expect(offset.dx, size.width, reason: 'dx width does not match');
      expect(offset.dy, size.height, reason: 'dy height does not match');
    });

    testRandom('toSize has x to size.dx and y to size.dy', (Random r) {
      final size = Size(r.nextDouble(), r.nextDouble());
      final point = size.toPoint();

      expect(point.x, size.width, reason: 'x width does not match');
      expect(point.y, size.height, reason: 'y height does not match');
    });

    testRandom(
        'toRect has left to 0, top to 0, width: size.dx and height: size.dy',
        (Random r) {
      final size = Size(r.nextDouble(), r.nextDouble());
      final rect = size.toRect();

      expect(rect.left, 0, reason: 'left should be 0 as init');
      expect(rect.top, 0, reason: 'top should be 0 as init');
      expect(rect.width, size.width, reason: 'width width does not match');
      expect(rect.height, size.height, reason: 'height height does not match');
    });
  });
}
