import 'package:flame/components.dart';
import 'package:meta/meta.dart';
import 'package:ordered_set/comparing.dart';
import 'package:ordered_set/queryable_ordered_set.dart';

/// This is a simple wrapper over [QueryableOrderedSet] to be used by
/// [Component].
///
/// Instead of immediately modifying the component list, all insertion
/// and removal operations are queued to be performed on the next tick.
///
/// This will avoid any concurrent modification exceptions while the game
/// iterates through the component list.
class ComponentSet extends QueryableOrderedSet<Component> {
  /// With default settings, creates a [ComponentSet] with the compare function
  /// that uses the Component's priority for sorting.
  ComponentSet({
    int Function(Component e1, Component e2)? comparator,
    bool? strictMode,
  }) : super(
          comparator: comparator ?? Comparing.on<Component>((c) => c.priority),
          strictMode: strictMode ?? defaultStrictMode,
        );

  static bool defaultStrictMode = false;

  /// Marked as internal, because the users shouldn't be able to add elements
  /// into the [ComponentSet] directly, bypassing the normal lifecycle handling.
  @internal
  @override
  bool add(Component component) => super.add(component);

  /// Marked as internal, because the users shouldn't be able to add elements
  /// into the [ComponentSet] directly, bypassing the normal lifecycle handling.
  @internal
  @override
  int addAll(Iterable<Component> components) => super.addAll(components);

  /// Marked as internal, because the users shouldn't be able to remove elements
  /// from the [ComponentSet] directly, bypassing the normal lifecycle handling.
  @internal
  @override
  bool remove(Component component) => super.remove(component);

  /// Marked as internal, because the users shouldn't be able to remove elements
  /// from the [ComponentSet] directly, bypassing the normal lifecycle handling.
  @internal
  @override
  Iterable<Component> removeAll(Iterable<Component> components) =>
      super.removeAll(components);

  /// Marked as internal, because the users shouldn't be able to remove elements
  /// from the [ComponentSet] directly, bypassing the normal lifecycle handling.
  @internal
  @override
  Iterable<Component> removeWhere(bool Function(Component element) test) =>
      super.removeWhere(test);

  /// Marked as internal, because the users shouldn't be able to remove elements
  /// from the [ComponentSet] directly, bypassing the normal lifecycle handling.
  @internal
  @override
  void clear() => super.clear();

  /// Whether the component set contains components or that there are components
  /// marked to be added later.
  @override
  bool get isNotEmpty => !isEmpty;

  /// Queries the component set (typically [Component.children]) for
  /// components of type [C].
  ///
  /// Example:
  ///
  /// ```dart
  /// final myComponents = world.children.query<MyCustomComponent>();
  /// ```
  ///
  /// This is equivalent to `world.children.whereType<MyCustomComponent>()`
  /// except that [query] is O(1).
  ///
  /// The function returns an [Iterable]. In past versions of Flame,
  /// it was a modifiable [List] but modifying this list would have been a bug.
  ///
  /// When [strictMode] is `true`, you *must* call [register]
  /// for every type [C] you desire to use. Use something like:
  ///
  /// ```dart
  /// world.children.register<MyCustomComponent>();
  /// ```
  @override
  Iterable<C> query<C extends Component>() {
    // We are returning an iterable (view) here to avoid hard-to-detect
    // bugs where the user assumes the query is a unique result list
    // and they start doing things like `removeWhere()`.
    // This would remove components from the component set itself
    // (but not from the game)!
    return super.query();
  }

  /// Sorts the components according to their `priority`s. This method is
  /// invoked by the framework when it knows that the priorities of the
  /// components in this set has changed.
  @internal
  void reorder() {
    final elements = toList();
    // bypass the wrapper because the components are already added
    super.clear();
    for (final element in elements) {
      super.add(element);
    }
  }
}
