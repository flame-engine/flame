import 'dart:collection';

import 'package:ordered_set/comparing.dart';
import 'package:ordered_set/queryable_ordered_set.dart';

import '../../components.dart';
import '../../game.dart';

/// This is a simple wrapper over [QueryableOrderedSet] to be used by
/// [Component].
///
/// Instead of immediately modifying the component list, all insertion
/// and removal operations are queued to be performed on the next tick.
///
/// This will avoid any concurrent modification exceptions while the game
/// iterates through the component list.
///
/// This wrapper also guaranteed that [Component.prepare], [Loadable.onLoad]
/// and all the lifecycle methods are called properly.
class ComponentSet extends QueryableOrderedSet<Component> {
  /// With default settings, creates a [ComponentSet] with the compare function
  /// that uses the Component's priority for sorting.
  ComponentSet({
    int Function(Component e1, Component e2)? comparator,
    bool strictMode = true,
  }) : super(
          comparator: comparator ?? Comparing.on<Component>((c) => c.priority),
          strictMode: strictMode,
        );

  // When we switch to Dart 2.15 this can be replaced with constructor tear-off
  static ComponentSet createDefault() => ComponentSet();

  /// Components to be added on the next update.
  ///
  /// The component list is only changed at the start of each update to avoid
  /// concurrency issues.
  final Set<Component> _addLater = {};

  /// Components to be removed on the next update.
  ///
  /// The component list is only changed at the start of each update to avoid
  /// concurrency issues.
  final Set<Component> _removeLater = {};

  /// Components whose priority changed since the last update.
  ///
  /// When priorities change we need to re-balance the component set, but
  /// we can only do that after each update to avoid concurrency issues.
  final Set<Component> _changedPriorities = {};

  /// Registers the component to be added on the next call to
  /// `updateComponentList()`.
  void addChild(Component component) {
    _addLater.add(component);
  }

  /// Marks a component to be removed from the components list on the next game
  /// tick.
  @override
  bool remove(Component c) {
    _removeLater.add(c);
    return true;
  }

  /// Marks a list of components to be removed from the components list on the
  /// next game tick. This will return the same list as sent in.
  @override
  Iterable<Component> removeAll(Iterable<Component> components) {
    _removeLater.addAll(components);
    return components;
  }

  /// Marks all existing components to be removed from the components list on
  /// the next game tick.
  @override
  void clear() {
    _removeLater.addAll(this);
  }

  /// Whether the component set is empty and that there are no components marked
  /// to be added later.
  @override
  bool get isEmpty => super.isEmpty && _addLater.isEmpty;

  /// Whether the component set contains components or that there are components
  /// marked to be added later.
  @override
  bool get isNotEmpty => !isEmpty;

  /// All the children that has been queued to be added to the component set.
  UnmodifiableListView<Component> get addLater {
    return UnmodifiableListView<Component>(_addLater);
  }

  /// Call this on your update method.
  ///
  /// This method effectuates any pending operations of insertion or removal,
  /// and thus actually modifies the components set.
  /// Note: do not call this while iterating the set.
  void updateComponentList() {
    _actuallyUpdatePriorities();
    _actuallyRemove();
    _actuallyAdd();
  }

  void _actuallyRemove() {
    _removeLater.addAll(where((c) => c.shouldRemove));
    _removeLater.forEach((c) {
      c.onRemove();
      super.remove(c);
      c.shouldRemove = false;
    });
    _removeLater.clear();
  }

  void _actuallyAdd() {
    _addLater.forEach((c) {
      super.add(c);
      c.isMounted = true;
    });
    _addLater.clear();
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
