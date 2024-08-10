import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame/src/geometry/ellipse_component.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EllipseComponent', () {
    test('width and height setters and getters', () {
      final component = EllipseComponent(width: 100, height: 50);
      expect(component.width, 100);
      expect(component.height, 50);

      component.width = 200;
      component.height = 100;
      expect(component.width, 200);
      expect(component.height, 100);
    });

    test('relative sizing', () {
      final parentSize = Vector2(300, 150);
      final component = EllipseComponent.relative(
        0.5,
        0.4,
        parentSize: parentSize,
      );

      expect(component.size.x, 150);
      expect(component.size.y, 60);
    });

    test('containsPoint', () {
      final component = EllipseComponent(width: 100, height: 50)
        ..position = Vector2(150, 150) // 中心放置在(150, 150)
        ..anchor = Anchor.center; // 确保以中心为锚点

      expect(component.containsPoint(Vector2(150, 150)), isTrue); // 在中心
      expect(component.containsPoint(Vector2(100, 100)), isFalse); // 不在椭圆内
      expect(component.containsPoint(Vector2(200, 150)), isTrue); // 在边界上
    });

    test('containsLocalPoint', () {
      final component = EllipseComponent(width: 100, height: 50);
      expect(component.containsLocalPoint(Vector2(50, 25)), isTrue);
      expect(component.containsLocalPoint(Vector2(100, 50)), isFalse);
    });

    test('lineSegmentIntersections', () {
      final component = EllipseComponent(width: 100, height: 50)
        ..position = Vector2(100, 50)
        ..anchor = Anchor.center;

      final lineSegment = LineSegment(
        Vector2(50, 50),
        Vector2(150, 50),
      );

      final intersections = component.lineSegmentIntersections(lineSegment);
      expect(intersections.length, 2);
      expect(intersections[0].x < intersections[1].x, isTrue);
    });
  });
}
