import 'package:flame/components.dart';
import 'package:flame/src/components/mixins/poolable.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Poolable mixin', () {
    test('reset sets position to zero', () {
      final component = _PoolablePositionComponent();
      component.reset();
      expect(component.position.x, 0);
      expect(component.position.y, 0);
    });

    group('lifecycle integration', () {
      testWithFlameGame('can reset while component is mounted', (game) async {
        final component = _PoolablePositionComponent();
        await game.world.add(component);
        await game.ready();

        expect(component.isMounted, true);

        component.reset();

        expect(component.resetCallCount, 1);
        expect(component.isMounted, true);
      });

      testWithFlameGame('can reset after component is removed', (game) async {
        final component = _PoolablePositionComponent();
        await game.world.add(component);
        await game.ready();

        component.removeFromParent();
        game.update(0);
        await component.removed;

        component.reset();

        expect(component.resetCallCount, 1);
        expect(component.isMounted, false);
      });

      testWithFlameGame('reset does not affect parent-child relationship', (
        game,
      ) async {
        final parent = _PoolablePositionComponent();
        final child = _PoolablePositionComponent();

        await game.world.add(parent);
        await parent.add(child);
        await game.ready();

        child.reset();

        expect(child.resetCallCount, 1);
        expect(child.parent, parent);
        expect(parent.children.contains(child), true);
      });
    });
  });
}

class _PoolablePositionComponent extends PositionComponent with Poolable {
  int resetCallCount = 0;

  @override
  void reset() {
    position.setZero();
    resetCallCount++;
  }
}
