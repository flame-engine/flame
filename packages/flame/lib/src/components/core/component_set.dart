import 'package:flame/components.dart';
import 'package:meta/meta.dart';
import 'package:ordered_set/ordered_set.dart';
import 'package:ordered_set/queryable_ordered_set.dart';

/// This is a simple wrapper over [QueryableOrderedSet].
/// It is used by the [Component] to hide the add and remove methods from the
/// user, since the user should be going through the [Component.add] and
/// [Component.remove] methods instead.
class ComponentSet extends QueryableOrderedSet<Component> {
  /// With default settings, creates a [ComponentSet] with the compare function
  /// that uses the Component's priority for sorting.
  ComponentSet({bool? strictMode})
      : super(
          OrderedSet.mapping<num, Component>(_componentPriorityMapper),
          strictMode: strictMode ?? defaultStrictMode,
        );

  static bool defaultStrictMode = false;

  static int _componentPriorityMapper(Component component) {
    return component.priority;
  }

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
}
