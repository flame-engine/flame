import 'package:collection/collection.dart';
import 'package:flame/camera.dart';
import 'package:flame/src/components/core/component.dart';
import 'package:meta/meta.dart';

/// [HasWorldRef] mixin provides the [worldRef] property, which is the cached
/// accessor for the world instance that this component belongs to.
///
/// The type [T] on the mixin is the type of your world class. This type will be
/// the type of the [worldRef] reference, and the mixin will check at runtime
/// that the actual type matches the expectation.
mixin HasWorldRef<T extends World> on Component {
  T? _world;

  /// Reference to the [World] instance that this component belongs to.
  T get worldRef => _world ??= _findWorldAndCheck();

  /// Allows you to set the world instance explicitly.
  /// This may be useful in tests.
  @visibleForTesting
  set worldRef(T? value) => _world = value;

  T? findWorld() {
    return ancestors(
          includeSelf: true,
        ).firstWhereOrNull((ancestor) => ancestor is T)
        as T?;
  }

  T _findWorldAndCheck() {
    final world = findWorld();
    assert(
      world != null,
      'Could not find a World instance of type $T',
    );
    return world!;
  }

  @override
  void onRemove() {
    super.onRemove();
    _world = null;
  }
}
