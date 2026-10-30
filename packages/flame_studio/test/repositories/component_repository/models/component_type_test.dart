import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(ComponentType, () {
    test('fromKey returns the matching type', () {
      expect(
        ComponentType.fromKey('rectangle'),
        equals(ComponentType.rectangle),
      );
      expect(ComponentType.fromKey('position'), equals(ComponentType.position));
      expect(ComponentType.fromKey('circle'), equals(ComponentType.circle));
      expect(ComponentType.fromKey('polygon'), equals(ComponentType.polygon));
      expect(
        ComponentType.fromKey('rectangleHitbox'),
        equals(ComponentType.rectangleHitbox),
      );
      expect(
        ComponentType.fromKey('circleHitbox'),
        equals(ComponentType.circleHitbox),
      );
      expect(
        ComponentType.fromKey('polygonHitbox'),
        equals(ComponentType.polygonHitbox),
      );
    });

    test('isHitbox is true only for hitboxes', () {
      expect(
        ComponentType.values.where((type) => type.isHitbox),
        equals([
          ComponentType.rectangleHitbox,
          ComponentType.circleHitbox,
          ComponentType.polygonHitbox,
        ]),
      );
    });

    test('hasVertices is true for polygons and polygon hitboxes', () {
      expect(
        ComponentType.values.where((type) => type.hasVertices),
        equals([ComponentType.polygon, ComponentType.polygonHitbox]),
      );
    });

    test('fromKey returns null for unknown keys', () {
      expect(ComponentType.fromKey('triangle'), isNull);
      expect(ComponentType.fromKey(null), isNull);
    });
  });

  group(PaintStyle, () {
    test('fromName returns the matching style', () {
      expect(PaintStyle.fromName('stroke'), equals(PaintStyle.stroke));
    });

    test('fromName returns null for unknown names', () {
      expect(PaintStyle.fromName('dotted'), isNull);
    });
  });
}
