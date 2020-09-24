import 'dart:ui';

import 'package:flame/components/position_component.dart';
import 'package:flame/components/sprite_component.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:test/test.dart';

void main() {
  group('component test', () {
    test('test get/set x/y or position', () {
      final PositionComponent c = SpriteComponent();
      c.position = Vector2(2.2, 3.4);
      expect(c.x, 2.2);
      expect(c.y, 3.4);

      c.position = Vector2(1.0, 0.0);
      expect(c.x, 1.0);
      expect(c.y, 0.0);
    });

    test('test get/set width/height or size', () {
      final PositionComponent c = SpriteComponent();
      c.size = Vector2(2.2, 3.4);
      expect(c.size.x, 2.2);
      expect(c.size.y, 3.4);

      c.size = Vector2(1.0, 0.0);
      expect(c.width, 1.0);
      expect(c.height, 0.0);
    });

    test('test get/set rect', () {
      final PositionComponent c = SpriteComponent();
      c.position = Vector2(0.0, 1.0);
      c.size = Vector2(2.0, 2.0);
      expect(c.toRect().left, 0.0);
      expect(c.toRect().top, 1.0);
      expect(c.toRect().width, 2.0);
      expect(c.toRect().height, 2.0);

      c.setByRect(const Rect.fromLTWH(10.0, 10.0, 1.0, 1.0));
      expect(c.x, 10.0);
      expect(c.y, 10.0);
      expect(c.width, 1.0);
      expect(c.height, 1.0);
    });
  });
}
