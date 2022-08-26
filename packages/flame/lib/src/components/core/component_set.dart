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

  @Deprecated('Use ComponentSet.new instead; will be removed in 1.3.0')
  ComponentSet.createDefault() : this();

  /// Components whose priority changed since the last update.
  ///
  /// When priorities change we need to re-balance the component set, but
  /// we can only do that after each update to avoid concurrency issues.
  final Set<Component> _changedPriorities = {};

  static bool defaultStrictMode = false;

  /// Marked as internal, because the users shouldn't be able to add elements
  /// into the [ComponentSet] directly, bypassing the normal lifecycle handling.
  @internal
  @override
  bool add(Component component) => super.add(component);

  /// Marked as internal, because the users shouldn't be able to remove elements
  /// from the [ComponentSet] directly, bypassing the normal lifecycle handling.
  @internal
  @override
  bool remove(Component component) => super.remove(component);

  /// Marked as internal, because the users shouldn't be able to remove elements
  /// from the [ComponentSet] directly, bypassing the normal lifecycle handling.
  @internal
  @override
  void clear() => super.clear();

  /// Whether the component set contains components or that there are components
  /// marked to be added later.
  @override
  bool get isNotEmpty => !isEmpty;

  /// Call this on your update method.
  ///
  /// This method effectuates any pending operations of insertion or removal,
  /// and thus actually modifies the components set.
  /// Note: do not call this while iterating the set.
  void updateComponentList() {
    _actuallyUpdatePriorities();
  }

  @override
  void rebalanceAll() {
    final elements = toList();
    // bypass the wrapper because the components are already added
    super.clear();
    elements.forEach(super.add);
  }

  @override
  void rebalanceWhere(bool Function(Component element) test) {
    // bypass the wrapper because the components are already added
    final elements = super.removeWhere(test).toList();
    elements.forEach(super.add);
  }

  /// Changes the priority of [component] and reorders the games component list.
  ///
  /// Returns true if changing the component's priority modified one of the
  /// components that existed directly on the game and false if it
  /// either was a child of another component, if it didn't exist at all or if
  /// it was a component added directly on the game but its priority didn't
  /// change.
  bool changePriority(
    Component component,
    int priority,
  ) {
    if (component.priority == priority) {
      return false;
    }
    component.changePriorityWithoutResorting(priority);
    _changedPriorities.add(component);
    return true;
  }

  void _actuallyUpdatePriorities() {
    var hasRootComponents = false;
    final parents = <Component>{};
    _changedPriorities.forEach((component) {
      final parent = component.parent;
      if (parent != null) {
        parents.add(parent);
      } else {
        hasRootComponents |= contains(component);
      }
    });
    if (hasRootComponents) {
      rebalanceAll();
    }
    parents.forEach((parent) => parent.reorderChildren());
    _changedPriorities.clear();
  }
}
