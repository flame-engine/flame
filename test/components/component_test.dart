import 'package:test/test.dart';
import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/position.dart';

void main() {
  group('component test', () {
    test('test get/set x/y or position', () {
      final PositionComponent c = SpriteComponent();
      c.x = 2.2;
      c.y = 3.4;
      expect(c.toPosition().x, 2.2);
      expect(c.toPosition().y, 3.4);

      c.setByPosition(Position(1.0, 0.0));
      expect(c.x, 1.0);
      expect(c.y, 0.0);
    });

    test('test get/set widt/height or size', () {
      final PositionComponent c = SpriteComponent();
      c.width = 2.2;
      c.height = 3.4;
      expect(c.toSize().x, 2.2);
      expect(c.toSize().y, 3.4);

      c.setBySize(Position(1.0, 0.0));
      expect(c.width, 1.0);
      expect(c.height, 0.0);
    });

    test('test get/set rect', () {
      final PositionComponent c = SpriteComponent();
      c.x = 0.0;
      c.y = 1.0;
      c.width = 2.0;
      c.height = 2.0;
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
