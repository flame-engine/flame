import 'dart:math' as math;
import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:flame_test/flame_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  group('RectExtension', () {
    test('toOffset dx is width and dy is height', () {
      const rect = Rect.fromLTWH(0, 0, 1, 2);
      final offset = rect.toOffset();
      expect(offset.dx, rect.width);
      expect(offset.dy, rect.height);
    });

    test('toVector2 x is width and y is height', () {
      const rect = Rect.fromLTWH(0, 0, 1, 2);
      final vector = rect.toVector2();
      expect(vector.x, rect.width);
      expect(vector.y, rect.height);
    });
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

    test('test from ui Rect to RectangleComponent', () {
      const r1 = Rect.fromLTWH(0, 10, 20, 30);
      final r2 = r1.toRectangleComponent();
      expect(r2.angle, 0);
      expect(r2.position.x, r1.left);
      expect(r2.position.y, r1.top);
      expect(r2.size.x, r1.width);
      expect(r2.size.y, r1.height);
    });

    test('test containsPoint calls contains on Rect', () {
      final rect = MockRect();
      final point = Vector2.zero();

      // mock contains result, but check it is called
      when(() => rect.contains(point.toOffset())).thenReturn(true);
      rect.containsPoint(point);
      verify(() => rect.contains(point.toOffset())).called(1);
    });

    testRandom('intersectsSegment', (Random r) {
      const rect = Rect.fromLTWH(0, 0, 1, 1);
      // create points left, above, right and under

      // y position [0, 1] but left to rect's left
      final left = Vector2(-.5, r.nextDouble() * 1);
      // x position [0, 1] but above rect's top
      final above = Vector2(r.nextDouble() * 1, -.5);
      // y position [0, 1] but right to rect's right
      final right = Vector2(1.5, r.nextDouble() * 1);
      // x position [0, 1] but under rect's bottom
      final under = Vector2(r.nextDouble() * 1, 1.5);
      expect(rect.intersectsSegment(left, above), true);
      expect(rect.intersectsSegment(left, under), true);
      expect(rect.intersectsSegment(right, above), true);
      expect(rect.intersectsSegment(right, under), true);
      expect(rect.intersectsSegment(left, right), true);
      expect(rect.intersectsSegment(under, above), true);

      // above the rect and left to rect's left
      final aboveLeft = Vector2(-.5, r.nextDouble() * 1 - 1);
      // above the rect and left to rect's left
      final aboveRight = Vector2(1.5, r.nextDouble() * 1 - 1);
      // under the rect and right to rect's right
      final underRight = Vector2(1.5, r.nextDouble() * 1 + 1);
      // under the rect and left to rect's left
      final underLeft = Vector2(-.5, r.nextDouble() * 1 + 1);
      expect(rect.intersectsSegment(aboveLeft, aboveRight), false);
      expect(rect.intersectsSegment(aboveLeft, underLeft), false);
      expect(rect.intersectsSegment(underLeft, underRight), false);
      expect(rect.intersectsSegment(underRight, aboveRight), false);

      // any y position but left to rect's left
      final nearLeft = Vector2(-.25, r.nextDouble() * 256);
      // any x position but above rect's top
      final nearAbove = Vector2(r.nextDouble() * 256, -.25);
      // any y position but right to rect's right
      final nearRight = Vector2(1.25, r.nextDouble() * 256);
      // any x position but under rect's bottom
      final nearUnder = Vector2(r.nextDouble() * 256, 1.25);

      expect(rect.intersectsSegment(left, nearLeft), false);
      expect(rect.intersectsSegment(above, nearAbove), false);
      expect(rect.intersectsSegment(right, nearRight), false);
      expect(rect.intersectsSegment(under, nearUnder), false);
    });

    testRandom('intersectsLineSegment is the same as intersectsSegment',
        (Random r) {
      final rect = Rect.fromLTWH(
        r.nextDouble(),
        r.nextDouble(),
        r.nextDouble(),
        r.nextDouble(),
      );
      final a = Vector2(r.nextDouble(), r.nextDouble());
      final b = Vector2(r.nextDouble(), r.nextDouble());
      final s = LineSegment(a, b);
      expect(rect.intersectsLineSegment(s), rect.intersectsSegment(a, b));
    });

    testRandom(
        'toVertices returns an array of [topLeft, topRight, bottomRight, '
        'bottomLeft]', (Random r) {
      final left = r.nextDouble();
      final top = r.nextDouble();
      final right = r.nextDouble();
      final bottom = r.nextDouble();

      final rect = Rect.fromLTRB(left, top, right, bottom);
      final vertices = rect.toVertices();
      expect(vertices.length, 4);
      expect(
        vertices[0],
        Vector2(left, top),
        reason: 'topLeft value is not right',
      );
      expect(
        vertices[1],
        Vector2(right, top),
        reason: 'topRight value is not right',
      );
      expect(
        vertices[2],
        Vector2(right, bottom),
        reason: 'bottomRight value is not right',
      );
      expect(
        vertices[3],
        Vector2(left, bottom),
        reason: 'bottomLeft value is not right',
      );
    });
    test('test transform', () {
      final matrix4 = Matrix4.translation(Vector3(10, 10, 0));
      const input = Rect.fromLTWH(0, 0, 10, 10);
      final result = input.transform(matrix4);

      expect(result.topLeft.toVector2(), closeToVector(Vector2(10, 10)));
      expect(result.bottomRight.toVector2(), closeToVector(Vector2(20, 20)));
    });

    testRandom('test bounding box', (Random r) {
      final points = List.generate(
        r.nextInt(15) + 2,
        (index) => Vector2(
          r.nextBool() ? r.nextDouble() : -r.nextDouble(),
          r.nextBool() ? r.nextDouble() : -r.nextDouble(),
        ),
      );

      final boudingBox = RectExtension.getBounds(points);
      final xList = points.map((e) => e.x);
      final yList = points.map((e) => e.y);
      expect(
        boudingBox.topLeft,
        Offset(
          xList.reduce(min),
          yList.reduce(min),
        ),
        reason: 'topLeft offset is not OK',
      );
      expect(
        boudingBox.bottomRight,
        Offset(
          xList.reduce(max),
          yList.reduce(max),
        ),
        reason: 'bottomRight offset is not OK',
      );
    });

    testRandom('fromCenter position and size is OK', (Random r) {
      final center = Vector2(r.nextDouble(), r.nextDouble());
      final width = r.nextDouble();
      final height = r.nextDouble();

      final rect = RectExtension.fromCenter(
        center: center,
        width: width,
        height: height,
      );

      expectDouble(rect.top, center.y - height / 2);
      expectDouble(rect.bottom, center.y + height / 2);
      expectDouble(rect.left, center.x - width / 2);
      expectDouble(rect.right, center.x + width / 2);
    });
  });
}

class MockRect extends Mock implements Rect {}
