import 'package:flame/src/components/mixins/poolable.dart';

/// A pool for managing reusable components that implement the [Poolable] mixin.
///
/// This class allows you to acquire and release components efficiently,
/// reducing the overhead of creating and destroying components frequently. 
/// When a component is released back to the pool, it is reset to its initial
/// state using the [Poolable.reset] method before being made available for
/// reuse.
///
/// Example usage:
/// ```dart
/// final bulletPool = ComponentPool<MyBullet>(
///   factory: () => MyBullet(),
///   maxSize: 50,
///   initialSize: 10,
/// );
/// ```
/// In this example, a pool of `MyBullet` components is created with a maximum
/// size of 50 and an initial size of 10. You can acquire bullets from the pool
/// when needed and release them back to the pool when they are no longer in
/// use.
///
/// Note: The pool does not automatically manage the lifecycle of components, so
/// it is the responsibility of the developer to ensure that components are
/// properly released back to the pool when they are no longer needed.
class ComponentPool<T extends Poolable> {
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
  /// that have been acquired but not yet released). It only counts the
  /// components that are ready to be acquired.
  int get availableCount => _available.length;

  /// Acquires a component from the pool. If the pool is empty, a new component
  /// is created using the factory function. Otherwise, the last available
  /// component is removed from the pool and returned.
  T acquire() {
    if (_available.isEmpty) {
      return _factory();
    }
    return _available.removeLast();
  }

  /// Releases a component back to the pool. The component is reset to its
  /// initial state using the [Poolable.reset] method before being added back
  /// to the pool. If the pool has reached its maximum size, the component will
  /// not be added back to the pool and will be discarded.
  ///
  /// If the component is currently mounted in the game, it will be removed from
  /// its parent before being reset and added back to the pool. This ensures
  /// that the component is properly removed from the component tree before
  /// being reused.
  Future<void> release(T component) async {
    if (component.isMounted) {
      if (!component.isRemoving) {
        component.removeFromParent();
      }
      await component.removed;
    }

    component.reset();

    if (_available.length < maxSize) {
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
