import 'package:flame/components.dart';
import 'package:flame/src/components/component_pool.dart';
import 'package:flame/src/components/mixins/poolable.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestPoolableComponent extends PositionComponent with Poolable {
  int resetCount = 0;
  bool wasReset = false;

  @override
  void reset() {
    resetCount++;
    wasReset = true;
    position.setZero();
    size.setZero();
  }
}

void main() {
  group('ComponentPool', () {
    group('initialization', () {
      test('creates pool with initial size', () {
        final pool = ComponentPool<_TestPoolableComponent>(
          factory: _TestPoolableComponent.new,
          initialSize: 5,
        );

        expect(pool.availableCount, 5);

        // All 5 components should be available in the pool
        final components = <_TestPoolableComponent>[];
        for (var i = 0; i < 5; i++) {
          components.add(pool.acquire());
        }

        // No new components created
        expect(pool.availableCount, 0);
      });

      test('respects max size when setting initial size', () {
        final pool = ComponentPool<_TestPoolableComponent>(
          factory: _TestPoolableComponent.new,
          initialSize: 20,
          maxSize: 10,
        );

        // Only maxSize components should be created
        expect(pool.availableCount, 10);
      });
    });

    group('acquire', () {
      test('returns new component when pool is empty', () async {
        final pool = ComponentPool<_TestPoolableComponent>(
          factory: _TestPoolableComponent.new,
        );

        expect(pool.availableCount, 0);
        final component = pool.acquire();

        await pool.release(component);
        expect(pool.availableCount, 1);
      });

      test('returns different instances when acquiring multiple times', () {
        final pool = ComponentPool<_TestPoolableComponent>(
          factory: _TestPoolableComponent.new,
        );

        final component1 = pool.acquire();
        final component2 = pool.acquire();

        expect(identical(component1, component2), false);
      });

      test('reuses released components', () {
        final pool = ComponentPool<_TestPoolableComponent>(
          factory: _TestPoolableComponent.new,
          maxSize: 5,
        );

        final component1 = pool.acquire();
        component1.position.setValues(10, 20);

        pool.release(component1);

        final component2 = pool.acquire();

        expect(identical(component1, component2), true);
        expect(component2.wasReset, true);
        expect(component2.position.x, 0);
        expect(component2.position.y, 0);
        expect(pool.availableCount, 0);
      });

      test('acquires from initial pool correctly', () {
        final pool = ComponentPool<_TestPoolableComponent>(
          factory: _TestPoolableComponent.new,
          initialSize: 3,
          maxSize: 5,
        );

        expect(pool.availableCount, 3);

        final components = <_TestPoolableComponent>[];
        for (var i = 0; i < 3; i++) {
          components.add(pool.acquire());
        }

        expect(pool.availableCount, 0);
        expect(identical(components[0], components[1]), false);
        expect(identical(components[1], components[2]), false);
      });
    });

    group('release', () {
      testWithFlameGame('releases and resets component', (game) async {
        final pool = ComponentPool<_TestPoolableComponent>(
          factory: _TestPoolableComponent.new,
          maxSize: 5,
        );

        expect(pool.availableCount, 0);

        final component = pool.acquire();
        component.position.setValues(100, 200);
        component.size.setValues(30, 40);

        await pool.release(component);

        expect(pool.availableCount, 1);
        expect(component.wasReset, true);
        expect(component.resetCount, 1);
        expect(component.position.x, 0);
        expect(component.position.y, 0);
        expect(component.size.x, 0);
        expect(component.size.y, 0);
      });

      testWithFlameGame(
        'removes mounted component before releasing',
        (game) async {
          final pool = ComponentPool<_TestPoolableComponent>(
            factory: _TestPoolableComponent.new,
            maxSize: 5,
          );

          final component = pool.acquire();
          await game.world.add(component);
          await game.ready();

          expect(component.isMounted, true);

          final releaseFuture = pool.release(component);
          game.update(0);
          await releaseFuture;

          expect(component.wasReset, true);
          expect(component.isMounted, false);
        },
      );

      testWithFlameGame(
        'does not add to pool if max size reached',
        (game) async {
          final pool = ComponentPool<_TestPoolableComponent>(
            factory: _TestPoolableComponent.new,
            maxSize: 2,
          );

          final component1 = pool.acquire();
          final component2 = pool.acquire();
          final component3 = pool.acquire();

          expect(pool.availableCount, 0);

          await pool.release(component1);
          await pool.release(component2);
          await pool.release(component3);

          game.update(0);

          expect(pool.availableCount, 2);

          final reacquired1 = pool.acquire();
          final reacquired2 = pool.acquire();
          final reacquired3 = pool.acquire();

          expect(identical(reacquired1, component2), true);
          expect(identical(reacquired2, component1), true);
          expect(identical(reacquired3, component3), false);
        },
      );

      testWithFlameGame(
        'handles component already in removing state',
        (game) async {
          final pool = ComponentPool<_TestPoolableComponent>(
            factory: _TestPoolableComponent.new,
            maxSize: 5,
          );

          final component = pool.acquire();
          await game.world.add(component);
          await game.ready();

          component.removeFromParent();

          final releaseFuture = pool.release(component);
          game.update(0);
          await releaseFuture;

          expect(component.isMounted, false);
          expect(component.wasReset, true);
        },
      );

      test('LIFO behavior (Last In First Out)', () async {
        final pool = ComponentPool<_TestPoolableComponent>(
          factory: _TestPoolableComponent.new,
          maxSize: 10,
        );

        final comp1 = pool.acquire();
        final comp2 = pool.acquire();
        final comp3 = pool.acquire();

        await pool.release(comp1);
        await pool.release(comp2);
        await pool.release(comp3);

        // Should acquire in LIFO order (comp3, comp2, comp1)
        final retrieved1 = pool.acquire();
        expect(identical(retrieved1, comp3), true); // comp3

        final retrieved2 = pool.acquire();
        expect(identical(retrieved2, comp2), true); // comp2

        final retrieved3 = pool.acquire();
        expect(identical(retrieved3, comp1), true); // comp1
      });
    });

    group('clear', () {
      test('removes all components from pool', () {
        final pool = ComponentPool<_TestPoolableComponent>(
          factory: _TestPoolableComponent.new,
          initialSize: 5,
          maxSize: 10,
        );

        expect(pool.availableCount, 5);
        pool.clear();
        expect(pool.availableCount, 0);
      });

      testWithFlameGame('does not affect components in use', (game) async {
        final pool = ComponentPool<_TestPoolableComponent>(
          factory: _TestPoolableComponent.new,
          maxSize: 5,
        );

        final component = pool.acquire();
        await game.world.add(component);
        await game.ready();

        pool.clear();

        // Component should still be mounted
        expect(component.isMounted, true);
      });
    });
  });
}
