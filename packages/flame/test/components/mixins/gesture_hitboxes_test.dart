import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GestureHitboxes', () {
    testWithFlameGame('component with hitbox contains point', (game) async {
      final component = _HitboxComponent();
      component.position.setValues(1.0, 1.0);
      component.anchor = Anchor.topLeft;
      component.size.setValues(2.0, 2.0);

      final hitbox = PolygonHitbox([
        Vector2(1, 0),
        Vector2(0, -1),
        Vector2(-1, 0),
        Vector2(0, 1),
      ]);

      component.add(hitbox);
      await game.ensureAdd(component);

      final point = component.position + component.size / 4;
      expect(component.containsPoint(point), isTrue);
    });

    testWithFlameGame(
      'hitbox is larger than the component and the point is outside '
      "of the component's size",
      (game) async {
        final component = _HitboxComponent();
        component.position.setValues(1.0, 1.0);
        component.anchor = Anchor.topLeft;
        component.size.setValues(2.0, 2.0);

        final hitbox = PolygonHitbox([
          Vector2(10, 0),
          Vector2(0, -10),
          Vector2(-10, 0),
          Vector2(0, 10),
        ]);

        component.add(hitbox);
        await game.ensureAdd(component);

        final point = Vector2(9, 0);
        expect(component.containsPoint(point), isTrue);
      },
    );

    testWithFlameGame('CircleHitbox is displaced within the parent component', (
      game,
    ) async {
      final component = _HitboxComponent();
      component.position.setAll(10);
      component.size.setValues(2.0, 2.0);

      final hitbox = CircleHitbox(
        position: Vector2(1.0, 1.5),
        radius: 0.5,
        anchor: Anchor.center,
      );

      component.add(hitbox);
      await game.ensureAdd(component);

      final point = component.position + hitbox.position;
      expect(component.containsPoint(point), isTrue);
      final outsidePoint = component.position + Vector2(1.0, 0.99);
      expect(component.containsPoint(outsidePoint), isFalse);
    });

    testWithFlameGame(
      'RectangleHitbox is displaced within the parent component',
      (game) async {
        final component = _HitboxComponent();
        component.position.setAll(10);
        component.size.setValues(2.0, 2.0);

        final hitbox = RectangleHitbox(
          position: Vector2(1.0, 1.5),
          size: Vector2.all(1.0),
          anchor: Anchor.center,
        );

        component.add(hitbox);
        await game.ensureAdd(component);

        final point = component.position + hitbox.position;
        expect(component.containsPoint(point), isTrue);
        final outsidePoint = component.position + Vector2(1.0, 0.99);
        expect(component.containsPoint(outsidePoint), isFalse);
      },
    );

    testWithFlameGame('get component hitboxes', (game) async {
      final component = _HitboxComponent();
      component.position.setValues(1.0, 1.0);
      component.anchor = Anchor.topLeft;
      component.size.setValues(2.0, 2.0);

      final polygonHitBox = PolygonHitbox([
        Vector2(1, 0),
        Vector2(0, -1),
        Vector2(-1, 0),
        Vector2(0, 1),
      ]);

      final circleHitBox = CircleHitbox();
      final rectangleHitBox = RectangleHitbox();

      component.addAll([polygonHitBox, circleHitBox, rectangleHitBox]);
      await game.ensureAdd(component);

      expect(component.hitboxes.length, 3);
      expect(component.hitboxes.contains(polygonHitBox), isTrue);
      expect(component.hitboxes.contains(circleHitBox), isTrue);
      expect(component.hitboxes.contains(rectangleHitBox), isTrue);
    });
  });
}

class _HitboxComponent extends PositionComponent with GestureHitboxes {}
