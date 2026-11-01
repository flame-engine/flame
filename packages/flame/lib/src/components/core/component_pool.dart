part of 'component.dart';

/// A mixin for components that can be reused through a [ComponentPool].
///
/// A component acquired from a pool is returned to it automatically once it is
/// detached from the component tree, so there is no manual release step for
/// components that are added to the tree.
///
/// Override [onAcquire] to reset the component's state before it is reused,
/// and [onRelease] to let go of resources it no longer needs while it waits in
/// the pool:
/// ```dart
/// class Bullet extends SpriteComponent with PooledComponent {
///   final Vector2 velocity = Vector2.zero();
///
///   @override
///   void onAcquire() {
///     velocity.setZero();
///   }
/// }
/// ```
mixin PooledComponent on Component {
  /// The pool that this component is currently acquired from, or `null` if the
  /// component is not in use.
  ComponentPool<PooledComponent>? _pool;

  /// Called when this component is handed out by [ComponentPool.acquire],
  /// both when it is newly created and when it is reused.
  ///
  /// Use it to reset any state left over from the previous use. It runs before
  /// you get the component back, so anything you set on the component after
  /// acquiring it (such as its position) is kept.
  void onAcquire() {}

  /// Called when this component is returned to the pool it was acquired from.
  ///
  /// This happens when the component is detached from the component tree, or
  /// when it is passed to [ComponentPool.release]. If the pool is already
  /// full, the component is discarded after this call.
  void onRelease() {}
}

/// A pool for managing reusable components.
///
/// This class allows you to efficiently reuse components, reducing the overhead
/// of creating and destroying them frequently. The pooled components must mix
/// in [PooledComponent].
///
/// Example usage:
/// ```dart
/// final bulletPool = ComponentPool<Bullet>(
///   factory: Bullet.new,
///   maxSize: 50,
///   initialSize: 10,
/// );
///
/// // Acquire a bullet from the pool, configure it, and add it to the game.
/// final bullet = bulletPool.acquire()
///   ..position.setValues(10, 20)
///   ..velocity.setValues(100, 0);
/// game.add(bullet);
///
/// // Later, when the bullet should be destroyed:
/// bullet.removeFromParent(); // Automatically returns to the pool.
/// ```
///
/// An acquired component is returned to the pool once it is detached from the
/// component tree: when it is removed from its parent, or when it is removed
/// before it could be mounted. It is returned right away, so it can be
/// acquired again in the same tick.
///
/// Moving the component to a new parent does not return it to the pool, and
/// neither does removing one of its ancestors, since the component stays
/// attached to its parent in both cases. To return an acquired component that
/// was never added to the component tree, call [release].
class ComponentPool<T extends PooledComponent>({
  /// The function that creates new components when the pool is empty.
  required final T Function() _factory,

  /// The maximum number of components that can be stored in the pool. If the
  /// pool reaches this limit, additional components released back to the pool
  /// will be discarded.
  final int maxSize = 100,

  /// The number of components that are created up front, at most [maxSize].
  int initialSize = 0,
}) {
  final List<T> _available = [];

  /// Creates a new component pool that creates components with the `factory`,
  /// pre-populated with [initialSize] components, and that keeps at most
  /// [maxSize] components available.
  this
    : assert(maxSize >= 0, 'maxSize must not be negative, but was $maxSize'),
      assert(
        initialSize >= 0,
        'initialSize must not be negative, but was $initialSize',
      ) {
    for (var i = 0; i < initialSize && i < maxSize; i++) {
      _available.add(_factory());
    }
  }

  /// The number of components currently available in the pool for acquisition.
  ///
  /// This does not include components that are currently in use (i.e., those
  /// that have been acquired but not yet returned to the pool).
  int get availableCount => _available.length;

  /// Acquires a component from the pool.
  ///
  /// If the pool is empty, a new component is created using the factory.
  /// Otherwise, the most recently returned component is reused. In both cases
  /// [PooledComponent.onAcquire] is called before the component is returned.
  ///
  /// The component is returned to the pool once it is detached from the
  /// component tree, so just call [Component.removeFromParent] when done
  /// with it.
  T acquire() {
    final component = _available.isEmpty ? _factory() : _available.removeLast();
    assert(
      component._pool == null,
      'The component $component is already acquired from a pool',
    );
    assert(
      component.parent == null,
      'The component $component is still attached to ${component.parent}, '
      'it must not be added to the component tree while it is in the pool',
    );
    component._pool = this;
    component.onAcquire();
    return component;
  }

  /// Returns an acquired [component] that was never added to the component
  /// tree back to the pool.
  ///
  /// Components that were added to the component tree are returned
  /// automatically once they are detached from it, so this must not be called
  /// for them.
  void release(T component) {
    assert(
      identical(component._pool, this),
      'The component $component is not acquired from this pool',
    );
    assert(
      component.parent == null,
      'The component $component is still attached to ${component.parent}, '
      'remove it from its parent instead, it is then released automatically',
    );
    if (identical(component._pool, this) && component.parent == null) {
      _release(component);
    }
  }

  void _release(T component) {
    component._pool = null;
    component.onRelease();
    if (_available.length < maxSize) {
      _available.add(component);
    }
  }

  /// Clears all available components from the pool. This can be useful if you
  /// want to free up memory or reset the pool state.
  ///
  /// This does not affect components that are currently in use, they are still
  /// returned to the pool once they are detached from the component tree.
  void clear() {
    _available.clear();
  }
}
