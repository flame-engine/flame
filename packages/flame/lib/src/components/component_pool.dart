import 'package:flame/components.dart';

/// A pool for managing reusable components.
///
/// This class allows you to efficiently reuse components, reducing the overhead
/// of creating and destroying them frequently. The pool automatically manages
/// component lifecycle by listening to the component's [Component.removed]
/// future, returning components to the pool when they are removed from their
/// parent.
///
/// Example usage:
/// ```dart
/// final bulletPool = ComponentPool<MyBullet>(
///   factory: () => MyBullet(),
///   maxSize: 50,
///   initialSize: 10,
/// );
///
/// // Acquire a bullet from the pool
/// final bullet = bulletPool.acquire();
/// // Configure the bullet as needed
/// bullet.position = Vector2(10, 20);
/// bullet.velocity = Vector2(100, 0);
/// // Add it to the game
/// game.add(bullet);
///
/// // Later, when the bullet should be destroyed:
/// bullet.removeFromParent(); // Automatically returns to pool
/// ```
///
/// The pool automatically returns components when they are removed from their
/// parent, so you don't need to manually release them. Simply call
/// [Component.removeFromParent] when the component should be destroyed, and it
/// will be automatically returned to the pool for reuse.
class ComponentPool<T extends Component> {
  final T Function() _factory;
  final List<T> _available = [];

  /// The maximum number of components that can be stored in the pool. If the
  /// pool reaches this limit, additional components released back to the pool
  /// will be discarded.
  final int maxSize;

  /// Creates a new component pool with the specified factory, maximum size, and
  /// initial size. The [factory] is a function that creates new instances of
  /// the component type. The [maxSize] parameter limits the number of
  /// components that can be stored in the pool, while the [initialSize]
  /// parameter determines how many components are created initially.
  ///
  /// If the [initialSize] exceeds the [maxSize], only [maxSize] components
  /// will be created and added to the pool.
  ComponentPool({
    required T Function() factory,
    this.maxSize = 100,
    int initialSize = 0,
  }) : _factory = factory {
    for (var i = 0; i < initialSize && i < maxSize; i++) {
      _available.add(_factory());
    }
  }

  /// The number of components currently available in the pool for acquisition.
  ///
  /// This does not include components that are currently in use (i.e., those
  /// that have been acquired but not yet returned to the pool). It only counts
  /// the components that are ready to be acquired.
  int get availableCount => _available.length;

  /// Acquires a component from the pool. If the pool is empty, a new component
  /// is created using the factory function. Otherwise, the last available
  /// component is removed from the pool and returned.
  ///
  /// A listener is automatically attached that will return the component to
  /// the pool when it is removed from its parent. The listener waits for the
  /// component to be [Component.mounted] first, then listens for
  /// [Component.removed]. This ensures recycled components (whose `removed`
  /// future is already completed) don't get immediately returned to the pool
  /// before they have a chance to mount.
  ///
  /// Just call [Component.removeFromParent] when done with the component.
  T acquire() {
    final component = _available.isEmpty ? _factory() : _available.removeLast();
    component.mounted.then((_) {
      component.removed.then((_) => _release(component));
    });
    return component;
  }

  /// Returns a component to the pool. This is called automatically when
  /// a component's [Component.removed] future completes (i.e., after it has
  /// been removed from its parent).
  ///
  /// The component is only added back to the pool if the pool has not reached
  /// its [maxSize].
  void _release(T component) {
    if (!_available.contains(component) && _available.length < maxSize) {
      _available.add(component);
    }
  }

  /// Clears all available components from the pool. This can be useful if you
  /// want to free up memory or reset the pool state.
  ///
  /// Note: This does not affect components that are currently in use.
  void clear() {
    _available.clear();
  }
}
