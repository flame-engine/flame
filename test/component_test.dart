import 'package:test/test.dart';
import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/position.dart';

void main() {
  group('component test', () {
    test('test get/set x/y or position', () {
      PositionComponent c = new SpriteComponent();
      c.x = 2.2;
      c.y = 3.4;
      expect(c.position.x, 2.2);
      expect(c.position.y, 3.4);

      c.position = new Position(1.0, 0.0);
      expect(c.x, 1.0);
      expect(c.y, 0.0);
    });

    test('test get/set widt/height or size', () {
      PositionComponent c = new SpriteComponent();
      c.width = 2.2;
      c.height = 3.4;
      expect(c.size.x, 2.2);
      expect(c.size.y, 3.4);

      c.size = new Position(1.0, 0.0);
      expect(c.width, 1.0);
      expect(c.height, 0.0);
    });

    test('test get/set rect', () {
      PositionComponent c = new SpriteComponent();
      c.x = 0.0;
      c.y = 1.0;
      c.width = 2.0;
      c.height = 2.0;
      expect(c.rect.left, 0.0);
      expect(c.rect.top, 1.0);
      expect(c.rect.width, 2.0);
      expect(c.rect.height, 2.0);

      c.rect = new Rect.fromLTWH(10.0, 10.0, 1.0, 1.0);
      expect(c.x, 10.0);
      expect(c.y, 10.0);
      expect(c.width, 1.0);
      expect(c.height, 1.0);
    });
  });
}
