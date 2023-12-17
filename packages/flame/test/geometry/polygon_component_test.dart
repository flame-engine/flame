import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:test/test.dart';

void main() {
  group('PolygonComponent', () {
    test('Hittest for PolygonComponent', () {
      final polygon = PolygonComponent(
        [
          Vector2(50, 50),
          Vector2(50, 150),
          Vector2(150, 150),
          Vector2(150, 50),
        ],
      );
      expect(polygon.containsLocalPoint(Vector2(75, 25)), isFalse);
      expect(polygon.containsLocalPoint(Vector2(75, 75)), isTrue);
      expect(polygon.containsLocalPoint(Vector2(75, 125)), isTrue);
      expect(polygon.containsLocalPoint(Vector2(25, 75)), isFalse);
      expect(polygon.containsLocalPoint(Vector2(125, 75)), isTrue);
    });
    
    test('Hittest for PolygonComponent.relative', () {
      final polygon = PolygonComponent.relative(
        [
          Vector2(-0.5, -0.5),
          Vector2(-0.5, 0.5),
          Vector2(0.5, 0.5),
          Vector2(0.5, -0.5),
        ],
        parentSize: Vector2.all(200),
      );
      expect(polygon.containsLocalPoint(Vector2(75, 25)), isFalse);
      expect(polygon.containsLocalPoint(Vector2(75, 75)), isTrue);
      expect(polygon.containsLocalPoint(Vector2(75, 125)), isTrue);
      expect(polygon.containsLocalPoint(Vector2(25, 75)), isFalse);
      expect(polygon.containsLocalPoint(Vector2(125, 75)), isTrue);
    });
  });
}