import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BoundedPositionBehavior', () {
    testWithFlameGame('target is the parent', (game) async {
      final bounds = Rectangle.fromLTRB(0, 0, 200, 100);
      final behavior = BoundedPositionBehavior(bounds: bounds);
      final component = PositionComponent()
        ..add(behavior)
        ..addToParent(game);
      await game.ready();

      expect(behavior.target, component);
      expect(behavior.bounds, bounds);
      expect(behavior.precision, 0.5);

      expect(component.position, Vector2(0, 0));
      component.position.x -= 1;
      game.update(0);
      expect(component.position, Vector2(0, 0));
      component.position.y += 3;
      game.update(0);
      expect(component.position, Vector2(0, 3));
      component.position = Vector2(-1, 2);
      game.update(0);
      expect(component.position, Vector2(0, 3));
    });

    test('bad precision', () {
      final shape = Circle(Vector2.zero(), 10);
      expect(
        () => BoundedPositionBehavior(bounds: shape, precision: 0),
        failsAssert('Precision must be positive: 0.0'),
      );
    });

    testWithFlameGame('bad parent', (game) async {
      final shape = Circle(Vector2.zero(), 10);
      final parent = Component()..addToParent(game);
      await game.ready();
      parent.add(BoundedPositionBehavior(bounds: shape));
      expect(
        () => game.update(0),
        failsAssert('Can only apply this behavior to a PositionProvider'),
      );
    });

    testWithFlameGame('adjust target position on mount', (game) async {
      final shape = Circle(Vector2.zero(), 10);
      final target = PositionComponent(position: Vector2(100, 0));
      game.add(target);
      target.add(BoundedPositionBehavior(bounds: shape));
      await game.ready();
      expect(target.position, closeToVector(Vector2(10, 0), 0.5));
    });

    testWithFlameGame('adjust target position on shape change', (game) async {
      final shape = Circle(Vector2.zero(), 10);
      final target = PositionComponent(position: Vector2(10, 0));
      final behavior = BoundedPositionBehavior(bounds: shape, precision: 0.1);
      game.add(target);
      target.add(behavior);
      await game.ready();
      expect(target.position, Vector2(10, 0));

      behavior.bounds = Circle(Vector2.zero(), 5);
      expect((behavior.bounds as Circle).radius, 5);
      expect(target.position, closeToVector(Vector2(5, 0), 0.1));
    });
  });
}
