import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:test/test.dart';

class RemoveComponent extends Component {
  int removeCounter = 0;

  @override
  void onRemove() {
    super.onRemove();
    removeCounter++;
  }
}

void main() {
  group('component test', () {
    test('test get/set x/y or position', () {
      final PositionComponent c = SpriteComponent();
      c.position.setValues(2.2, 3.4);
      expect(c.x, 2.2);
      expect(c.y, 3.4);

      c.position.setValues(1.0, 0.0);
      expect(c.x, 1.0);
      expect(c.y, 0.0);
    });

    test('test get/set width/height or size', () {
      final PositionComponent c = SpriteComponent();
      c.size.setValues(2.2, 3.4);
      expect(c.size.x, 2.2);
      expect(c.size.y, 3.4);

      c.size.setValues(1.0, 0.0);
      expect(c.width, 1.0);
      expect(c.height, 0.0);
    });

    test('test get/set rect', () {
      final PositionComponent c = SpriteComponent();
      c.position.setValues(0.0, 1.0);
      c.size.setValues(2.0, 2.0);
      final rect = c.toRect();
      expect(rect.left, 0.0);
      expect(rect.top, 1.0);
      expect(rect.width, 2.0);
      expect(rect.height, 2.0);

      c.setByRect(const Rect.fromLTWH(10.0, 10.0, 1.0, 1.0));
      expect(c.x, 10.0);
      expect(c.y, 10.0);
      expect(c.width, 1.0);
      expect(c.height, 1.0);
    });

    test('test get/set rect with anchor', () {
      final PositionComponent c = SpriteComponent();
      c.position.setValues(0.0, 1.0);
      c.size.setValues(2.0, 2.0);
      c.anchor = Anchor.center;
      final rect = c.toRect();
      expect(rect.left, -1.0);
      expect(rect.top, 0.0);
      expect(rect.width, 2.0);
      expect(rect.height, 2.0);

      c.setByRect(const Rect.fromLTWH(10.0, 10.0, 1.0, 1.0));
      expect(c.x, 10.5);
      expect(c.y, 10.5);
      expect(c.width, 1.0);
      expect(c.height, 1.0);
    });

    test('test get/set anchorPosition', () {
      final PositionComponent c = SpriteComponent();
      c.position.setValues(0.0, 1.0);
      c.size.setValues(2.0, 2.0);
      c.anchor = Anchor.center;
      final anchorPosition = c.topLeftPosition;
      expect(anchorPosition.x, -1.0);
      expect(anchorPosition.y, 0.0);
    });

    test('test remove and shouldRemove', () {
      final c1 = SpriteComponent();
      expect(c1.shouldRemove, equals(false));
      c1.removeFromParent();
      expect(c1.shouldRemove, equals(true));

      final c2 = SpriteAnimationComponent();
      expect(c2.shouldRemove, equals(false));
      c2.removeFromParent();
      expect(c2.shouldRemove, equals(true));

      c2.shouldRemove = false;
      expect(c2.shouldRemove, equals(false));
    });

    test('remove and re-add should not double trigger onRemove', () {
      final game = FlameGame()..onGameResize(Vector2.zero());
      final component = RemoveComponent();

      game.add(component);
      game.update(0);
      component.removeFromParent();
      game.update(0);
      expect(component.removeCounter, 1);
      component.shouldRemove = false;
      component.removeCounter = 0;
      game.add(component);
      game.update(0);
      expect(component.removeCounter, 0);
      expect(game.children.length, 1);
    });
  });
}
