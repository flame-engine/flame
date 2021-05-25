import 'dart:math' as math;

import 'package:flame/extensions.dart';
import 'package:test/test.dart';

void main() {
  group('Rect test', () {
    test('test from ui Rect to math Rectangle', () {
      const r1 = Rect.fromLTWH(0, 10, 20, 30);
      final r2 = r1.toMathRectangle();
      expect(r2.top, r1.top);
      expect(r2.bottom, r1.bottom);
      expect(r2.left, r1.left);
      expect(r2.right, r1.right);
      expect(r2.width, r1.width);
      expect(r2.height, r1.height);
    });

    test('test from math Rectangle to ui Rect', () {
      const r1 = math.Rectangle(0, 10, 20, 30);
      final r2 = r1.toRect();
      expect(r2.top, r1.top);
      expect(r2.bottom, r1.bottom);
      expect(r2.left, r1.left);
      expect(r2.right, r1.right);
      expect(r2.width, r1.width);
      expect(r2.height, r1.height);
    });

    test('test from ui Rect to geometry Rectangle', () {
      const r1 = Rect.fromLTWH(0, 10, 20, 30);
      final r2 = r1.toGeometryRectangle();
      expect(r2.angle, 0);
      expect(r2.size.x, r1.width);
      expect(r2.size.y, r1.height);
      expect(r2.position.x, r1.left);
      expect(r2.position.y, r1.top);
    });
  });
}
