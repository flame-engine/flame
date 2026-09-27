import 'dart:ui';

import 'package:flame/components.dart';
import 'package:test/test.dart';

void main() {
  test('fromPath preserves the path bounds', () {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(0, 0, 64, 64),
          const Radius.circular(10),
        ),
      );

    final polygon = PolygonComponent.fromPath(path);

    expect(polygon.size.x, closeTo(64, 1e-10));
    expect(polygon.size.y, closeTo(64, 1e-10));
    expect(polygon.vertices.first, isNot(polygon.vertices.last));
  });

  test('fromPath picks the requested contour of the path', () {
    final path = Path()
      ..addRect(const Rect.fromLTWH(0, 0, 10, 10))
      ..addPolygon(const [
        Offset(20, 20),
        Offset(50, 20),
        Offset(20, 60),
      ], true);

    expect(PolygonComponent.fromPath(path).vertices, hasLength(4));
    final triangle = PolygonComponent.fromPath(path, contour: 1);
    expect(triangle.vertices, hasLength(3));
    expect(triangle.size, Vector2(30, 40));
    expect(
      () => PolygonComponent.fromPath(path, contour: 2),
      throwsRangeError,
    );
  });
}
