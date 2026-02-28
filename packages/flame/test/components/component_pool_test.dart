import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestComponent extends PositionComponent {
  int mountCount = 0;

  @override
  void onMount() {
    super.onMount();
    mountCount++;
    position.setZero();
    size.setZero();
  }
}

void main() {
  group('ComponentPool', () {
    group('initialization', () {
      test('pre-populates pool with initialSize components', () {
        final pool = ComponentPool<_TestComponent>(
          factory: _TestComponent.new,
          initialSize: 5,
        );

        expect(pool.availableCount, 5);

        final components = <_TestComponent>{};
        for (var i = 0; i < 5; i++) {
          components.add(pool.acquire());
        }

        // All 5 should be unique instances from the pool
        expect(components.length, 5);
        expect(pool.availableCount, 0);
      });

      test('clamps initial size to max size', () {
        final pool = ComponentPool<_TestComponent>(
          factory: _TestComponent.new,
          initialSize: 20,
          maxSize: 10,
        );

        expect(pool.availableCount, 10);
      });
    });

    group('acquire', () {
      test('creates distinct instances via factory when pool is empty', () {
        final pool = ComponentPool<_TestComponent>(
          factory: _TestComponent.new,
        );

        expect(pool.availableCount, 0);

        final component1 = pool.acquire();
        final component2 = pool.acquire();

        expect(identical(component1, component2), false);
        expect(pool.availableCount, 0);
      });

      testWithFlameGame(
        'returns same instance after it is removed from parent',
        (game) async {
          final pool = ComponentPool<_TestComponent>(
            factory: _TestComponent.new,
            maxSize: 5,
          );

          final original = pool.acquire();
          original.position.setValues(10, 20);
          await game.add(original);
          await game.ready();

          original.removeFromParent();
          game.update(0);
          await game.ready();

          final reacquired = pool.acquire();

          expect(identical(original, reacquired), true);
          expect(pool.availableCount, 0);
        },
      );
    });

    group('automatic release', () {
      testWithFlameGame(
        'returns component to pool when removed from parent',
        (game) async {
          final pool = ComponentPool<_TestComponent>(
            factory: _TestComponent.new,
            maxSize: 5,
          );

          final component = pool.acquire();
          await game.add(component);
          await game.ready();

          expect(component.isMounted, true);
          expect(pool.availableCount, 0);

          component.removeFromParent();
          game.update(0);
          await game.ready();

          expect(component.isMounted, false);
          expect(pool.availableCount, 1);
        },
      );

      testWithFlameGame(
        'does not prematurely release recycled component before mounting',
        (game) async {
          final pool = ComponentPool<_TestComponent>(
            factory: _TestComponent.new,
            maxSize: 5,
          );

          // First cycle: acquire → mount → remove
          final comp = pool.acquire();
          await game.add(comp);
          await game.ready();
          comp.removeFromParent();
          game.update(0);
          await game.ready();

          expect(pool.availableCount, 1);

          // Re-acquire the recycled component. At this point its `removed`
          // future is already completed (Future.value()). Without the
          // mounted.then guard, _release would fire as a microtask and
          // return it to the pool immediately.
          final recycled = pool.acquire();
          expect(identical(comp, recycled), true);
          expect(pool.availableCount, 0);

          // Mount it again
          await game.add(recycled);
          await game.ready();

          // Still in use (mounted, not yet removed)
          expect(pool.availableCount, 0);

          // Remove it — now it should return to the pool
          recycled.removeFromParent();
          game.update(0);
          await game.ready();

          expect(pool.availableCount, 1);
        },
      );

      testWithFlameGame(
        'supports multiple acquire-remove cycles on same component',
        (game) async {
          final pool = ComponentPool<_TestComponent>(
            factory: _TestComponent.new,
            maxSize: 1,
          );

          for (var i = 0; i < 3; i++) {
            final component = pool.acquire();
            component.position.setValues(100, 200);
            await game.add(component);
            await game.ready();

            expect(component.isMounted, true);

            component.removeFromParent();
            game.update(0);
            await game.ready();

            expect(pool.availableCount, 1);
          }

          // All 3 cycles should have reused the same instance
          final finalComponent = pool.acquire();
          expect(finalComponent.mountCount, 3);
        },
      );

      testWithFlameGame(
        'discards components when pool is at max size',
        (game) async {
          final pool = ComponentPool<_TestComponent>(
            factory: _TestComponent.new,
            maxSize: 2,
          );

          final component1 = pool.acquire();
          final component2 = pool.acquire();
          final component3 = pool.acquire();

          await game.add(component1);
          await game.add(component2);
          await game.add(component3);
          await game.ready();

          component1.removeFromParent();
          component2.removeFromParent();
          component3.removeFromParent();
          game.update(0);
          await game.ready();

          // Only 2 of 3 should be kept
          expect(pool.availableCount, 2);

          // After exhausting the pool, a new instance is created
          pool.acquire();
          pool.acquire();
          final fresh = pool.acquire();

          expect(
            [
              component1,
              component2,
              component3,
            ].every((c) => !identical(c, fresh)),
            true,
          );
        },
      );

      testWithFlameGame(
        'returns components in LIFO order',
        (game) async {
          final pool = ComponentPool<_TestComponent>(
            factory: _TestComponent.new,
            maxSize: 10,
          );

          final comp1 = pool.acquire();
          final comp2 = pool.acquire();
          final comp3 = pool.acquire();

          await game.add(comp1);
          await game.add(comp2);
          await game.add(comp3);
          await game.ready();

          comp1.removeFromParent();
          comp2.removeFromParent();
          comp3.removeFromParent();
          game.update(0);
          await game.ready();

          expect(identical(pool.acquire(), comp3), true);
          expect(identical(pool.acquire(), comp2), true);
          expect(identical(pool.acquire(), comp1), true);
        },
      );
    });

    group('clear', () {
      test('removes all available components from pool', () {
        final pool = ComponentPool<_TestComponent>(
          factory: _TestComponent.new,
          initialSize: 5,
          maxSize: 10,
        );

        expect(pool.availableCount, 5);
        pool.clear();
        expect(pool.availableCount, 0);
      });

      testWithFlameGame(
        'does not affect mounted components',
        (game) async {
          final pool = ComponentPool<_TestComponent>(
            factory: _TestComponent.new,
            maxSize: 5,
          );

          final component = pool.acquire();
          await game.add(component);
          await game.ready();

          pool.clear();

          expect(component.isMounted, true);
        },
      );
    });
  });
}
