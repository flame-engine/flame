import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestComponent() extends PositionComponent with PooledComponent {
  int mountCount = 0;
  int removeCount = 0;
  int acquireCount = 0;
  int releaseCount = 0;

  @override
  void onAcquire() {
    acquireCount++;
    position.setZero();
  }

  @override
  void onRelease() => releaseCount++;

  @override
  void onMount() {
    super.onMount();
    mountCount++;
  }

  @override
  void onRemove() {
    removeCount++;
    super.onRemove();
  }
}

class _RemovesChildOnRemove() extends Component {
  late final Component child;

  @override
  void onRemove() {
    child.removeFromParent();
    super.onRemove();
  }
}

ComponentPool<_TestComponent> _createPool({
  int maxSize = 100,
  int initialSize = 0,
}) {
  return ComponentPool<_TestComponent>(
    factory: _TestComponent.new,
    maxSize: maxSize,
    initialSize: initialSize,
  );
}

void main() {
  group('ComponentPool', () {
    group('initialization', () {
      test('pre-populates pool with initialSize components', () {
        final pool = _createPool(initialSize: 5);

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
        final pool = _createPool(initialSize: 20, maxSize: 10);

        expect(pool.availableCount, 10);
      });

      test('asserts that the sizes are not negative', () {
        expect(
          () => _createPool(maxSize: -1),
          throwsA(isA<AssertionError>()),
        );
        expect(
          () => _createPool(initialSize: -1),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('acquire', () {
      test('creates distinct instances via factory when pool is empty', () {
        final pool = _createPool();

        expect(pool.availableCount, 0);

        final component1 = pool.acquire();
        final component2 = pool.acquire();

        expect(identical(component1, component2), false);
        expect(pool.availableCount, 0);
      });

      test('calls onAcquire for new and reused components', () {
        final pool = _createPool();

        final component = pool.acquire();
        expect(component.acquireCount, 1);

        component.position.setValues(10, 20);
        pool.release(component);

        final reacquired = pool.acquire();
        expect(identical(component, reacquired), true);
        expect(reacquired.acquireCount, 2);
        expect(reacquired.position, Vector2.zero());
      });

      testWithFlameGame(
        'returns same instance after it is removed from parent',
        (game) async {
          final pool = _createPool(maxSize: 5);

          final original = pool.acquire();
          await game.ensureAdd(original);

          original.removeFromParent();
          game.update(0);

          final reacquired = pool.acquire();

          expect(identical(original, reacquired), true);
          expect(pool.availableCount, 0);
        },
      );

      testWithFlameGame(
        'asserts when a component in the pool was added to the tree',
        (game) async {
          final pool = _createPool();

          final component = pool.acquire();
          await game.ensureAdd(component);
          component.removeFromParent();
          game.update(0);

          // A stale reference is used to add the component back, while it is
          // still in the pool.
          await game.ensureAdd(component);

          expect(pool.acquire, throwsA(isA<AssertionError>()));
        },
      );
    });

    group('automatic release', () {
      testWithFlameGame(
        'returns component to pool when removed from parent',
        (game) async {
          final pool = _createPool(maxSize: 5);

          final component = pool.acquire();
          await game.ensureAdd(component);

          expect(component.isMounted, true);
          expect(pool.availableCount, 0);

          component.removeFromParent();
          game.update(0);

          expect(component.isMounted, false);
          expect(component.releaseCount, 1);
          expect(pool.availableCount, 1);
        },
      );

      testWithFlameGame(
        'makes the component available within the same tick',
        (game) async {
          final pool = _createPool();

          final component = pool.acquire();
          await game.ensureAdd(component);

          component.removeFromParent();
          // The lifecycle events are processed synchronously by update, the
          // component must be available without awaiting anything.
          game.update(0);

          expect(pool.availableCount, 1);
        },
      );

      testWithFlameGame(
        'does not release a component that is moved to a new parent',
        (game) async {
          final pool = _createPool();
          final parentA = Component();
          final parentB = Component();
          await game.ensureAddAll([parentA, parentB]);

          final component = pool.acquire();
          await parentA.ensureAdd(component);

          component.parent = parentB;
          await game.ready();

          expect(component.isMounted, true);
          expect(component.parent, parentB);
          expect(component.releaseCount, 0);
          expect(pool.availableCount, 0);
          expect(identical(pool.acquire(), component), false);

          // It is still owned by the pool, and returns to it once removed from
          // its new parent.
          component.removeFromParent();
          game.update(0);

          expect(component.releaseCount, 1);
          expect(pool.availableCount, 1);
        },
      );

      testWithFlameGame(
        'does not release a component whose ancestor is removed',
        (game) async {
          final pool = _createPool();
          final container = Component();
          await game.ensureAdd(container);

          final component = pool.acquire();
          await container.ensureAdd(component);

          container.removeFromParent();
          game.update(0);

          expect(component.isRemoved, true);
          expect(component.parent, container);
          expect(component.releaseCount, 0);
          expect(pool.availableCount, 0);

          // The component comes back along with its ancestor.
          await game.ensureAdd(container);

          expect(component.isMounted, true);
          expect(component.mountCount, 2);
          expect(component.removeCount, 1);
          expect(pool.availableCount, 0);
        },
      );

      testWithFlameGame(
        'releases a component detached from a removed ancestor',
        (game) async {
          final pool = _createPool();
          final container = Component();
          await game.ensureAdd(container);

          final component = pool.acquire();
          await container.ensureAdd(component);

          container.removeFromParent();
          game.update(0);
          expect(pool.availableCount, 0);

          container.remove(component);

          expect(component.parent, isNull);
          expect(component.releaseCount, 1);
          expect(pool.availableCount, 1);
          expect(component.removeCount, 1);
        },
      );

      testWithFlameGame(
        'releases a component removed by its ancestor during onRemove',
        (game) async {
          final pool = _createPool();
          final container = _RemovesChildOnRemove();
          await game.ensureAdd(container);

          final component = pool.acquire();
          container.child = component;
          await container.ensureAdd(component);

          container.removeFromParent();
          game.update(0);

          expect(component.parent, isNull);
          expect(component.releaseCount, 1);
          expect(pool.availableCount, 1);
        },
      );

      testWithFlameGame(
        'releases a component removed before it was mounted',
        (game) async {
          final pool = _createPool();

          final component = pool.acquire();
          game.add(component);
          component.removeFromParent();

          expect(component.parent, isNull);
          expect(component.releaseCount, 1);
          expect(pool.availableCount, 1);

          game.update(0);
          await game.ready();

          expect(component.isMounted, false);
          expect(component.releaseCount, 1);
          expect(pool.availableCount, 1);
        },
      );

      test(
        'releases a component removed from a parent that is not mounted',
        () {
          final pool = _createPool();
          final container = Component();

          final component = pool.acquire();
          container.add(component);
          container.remove(component);

          expect(component.parent, isNull);
          expect(component.releaseCount, 1);
          expect(pool.availableCount, 1);
        },
      );

      testWithFlameGame(
        'supports multiple acquire-remove cycles on same component',
        (game) async {
          final pool = _createPool(maxSize: 1);

          for (var i = 0; i < 3; i++) {
            final component = pool.acquire();
            component.position.setValues(100, 200);
            await game.ensureAdd(component);

            expect(component.isMounted, true);

            component.removeFromParent();
            game.update(0);

            expect(pool.availableCount, 1);
          }

          // All 3 cycles should have reused the same instance
          final finalComponent = pool.acquire();
          expect(finalComponent.mountCount, 3);
          expect(finalComponent.releaseCount, 3);
          expect(finalComponent.acquireCount, 4);
        },
      );

      testWithFlameGame(
        'can be re-acquired and re-added within the same tick',
        (game) async {
          final pool = _createPool();

          final component = pool.acquire();
          await game.ensureAdd(component);

          component.removeFromParent();
          game.update(0);

          final reacquired = pool.acquire();
          expect(identical(component, reacquired), true);
          await game.ensureAdd(reacquired);

          expect(reacquired.isMounted, true);
          expect(reacquired.mountCount, 2);

          reacquired.removeFromParent();
          game.update(0);

          expect(pool.availableCount, 1);
          expect(reacquired.releaseCount, 2);
        },
      );

      testWithFlameGame(
        'discards components when pool is at max size',
        (game) async {
          final pool = _createPool(maxSize: 2);

          final component1 = pool.acquire();
          final component2 = pool.acquire();
          final component3 = pool.acquire();

          await game.ensureAddAll([component1, component2, component3]);

          component1.removeFromParent();
          component2.removeFromParent();
          component3.removeFromParent();
          game.update(0);

          // Only 2 of 3 should be kept, but all of them are released.
          expect(pool.availableCount, 2);
          expect(component3.releaseCount, 1);

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
          final pool = _createPool(maxSize: 10);

          final comp1 = pool.acquire();
          final comp2 = pool.acquire();
          final comp3 = pool.acquire();

          await game.ensureAddAll([comp1, comp2, comp3]);

          comp1.removeFromParent();
          comp2.removeFromParent();
          comp3.removeFromParent();
          game.update(0);

          expect(identical(pool.acquire(), comp3), true);
          expect(identical(pool.acquire(), comp2), true);
          expect(identical(pool.acquire(), comp1), true);
        },
      );

      testWithFlameGame(
        'does not release components that were not acquired',
        (game) async {
          final pool = _createPool(initialSize: 1);

          final component = _TestComponent();
          await game.ensureAdd(component);
          component.removeFromParent();
          game.update(0);

          expect(component.releaseCount, 0);
          expect(pool.availableCount, 1);
        },
      );
    });

    group('release', () {
      test('returns a component that was never added to the tree', () {
        final pool = _createPool();

        final component = pool.acquire();
        pool.release(component);

        expect(component.releaseCount, 1);
        expect(pool.availableCount, 1);
        expect(identical(pool.acquire(), component), true);
      });

      test('asserts that the component is acquired from this pool', () {
        final pool = _createPool();
        final otherPool = _createPool();

        final component = otherPool.acquire();

        expect(() => pool.release(component), throwsA(isA<AssertionError>()));
        expect(
          () => pool.release(_TestComponent()),
          throwsA(isA<AssertionError>()),
        );
        expect(pool.availableCount, 0);
      });

      test('asserts when the component is released twice', () {
        final pool = _createPool();

        final component = pool.acquire();
        pool.release(component);

        expect(() => pool.release(component), throwsA(isA<AssertionError>()));
        expect(pool.availableCount, 1);
      });

      testWithFlameGame(
        'asserts that the component is not attached to a parent',
        (game) async {
          final pool = _createPool();

          final component = pool.acquire();
          await game.ensureAdd(component);

          expect(() => pool.release(component), throwsA(isA<AssertionError>()));
          expect(pool.availableCount, 0);
        },
      );
    });

    group('clear', () {
      test('removes all available components from pool', () {
        final pool = _createPool(initialSize: 5, maxSize: 10);

        expect(pool.availableCount, 5);
        pool.clear();
        expect(pool.availableCount, 0);
      });

      testWithFlameGame(
        'does not affect components in use',
        (game) async {
          final pool = _createPool(maxSize: 5);

          final component = pool.acquire();
          await game.ensureAdd(component);

          pool.clear();

          expect(component.isMounted, true);

          component.removeFromParent();
          game.update(0);

          expect(pool.availableCount, 1);
        },
      );
    });
  });
}
