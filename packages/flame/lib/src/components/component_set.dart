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

  /// This is the "prepare" function that will be called *before* the
  /// component is added to the component list by the add/addAll methods.
  /// It is also called when the component changes parent.
  final Component parent;

  ComponentSet(
    int Function(Component e1, Component e2)? compare,
    this.parent,
  ) : super(compare);

  /// Prepares and registers one component to be added on the next game tick.
  ///
  /// This is the interface compliant version; if you want to provide an
  /// explicit gameRef or await for the [Loadable.onLoad], use [addChild].
  ///
  /// Note: the component is only added on the next tick. This method always
  /// returns true.
  @override
  bool add(Component c) {
    addChild(c);
    return true;
  }

  /// Prepares and registers a list of components to be added on the next game
  /// tick.
  ///
  /// This is the interface compliant version; if you want to provide an
  /// explicit gameRef or await for the [Loadable.onLoad], use [addChild].
  ///
  /// Note: the components are only added on the next tick. This method always
  /// returns the total length of the provided list.
  @override
  int addAll(Iterable<Component> components) {
    addChildren(components);
    return components.length;
  }

  /// Prepares and registers one component to be added on the next game tick.
  ///
  /// This allows you to provide a specific gameRef if this component is being
  /// added from within another component that is already on a FlameGame.
  /// You can await for the onLoad function, if present.
  /// This method can be considered sync for all intents and purposes if no
  /// onLoad is provided by the component.
  Future<void> addChild(Component component) async {
    component.prepare(parent);
    if (!component.isPrepared) {
      // Since the components won't be added until a proper game is added
      // further up in the tree we can add them to the _addLater list and
      // then re-add them once there is a proper root.
      _addLater.add(component);
      return;
    }
    // [Component.onLoad] (if it is defined) should only run the first time that
    // a component is added to a parent.
    if (!component.isLoaded) {
      final onLoad = component.onLoadCache;
      if (onLoad != null) {
        await onLoad;
      }
      component.isLoaded = true;
    }

    // Should run every time the component gets a new parent, including its
    // first parent.
    component.onMount();
    if (component.children.isNotEmpty) {
      await component.reAddChildren();
    }

    _addLater.add(component);
  }

  /// Prepares and registers a list of component to be added on the next game
  /// tick.
  ///
  /// See [addChild] for more details.
  Future<void> addChildren(Iterable<Component> components) async {
    final ps = components.map(addChild);
    await Future.wait(ps);
  }

  /// Marks a component to be removed from the components list on the next game
  /// tick.
  @override
  bool remove(Component c) {
    _removeLater.add(c);
    return true;
  }

  /// Marks a list of components to be removed from the components list on the
  /// next game tick.
  void removeAll(Iterable<Component> components) {
    _removeLater.addAll(components);
  }

  /// Marks all existing components to be removed from the components list on
  /// the next game tick.
  @override
  void clear() {
    _removeLater.addAll(this);
  }

  /// Materializes the component list in reversed order.
  Iterable<Component> reversed() {
    return toList().reversed;
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
    _removeLater.addAll(where((c) => c.shouldRemove));
    _removeLater.forEach((c) {
      c.onRemove();
      super.remove(c);
      c.shouldRemove = false;
    });
    _removeLater.clear();

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

  /// Creates a [ComponentSet] with a default value for the compare function,
  /// using the Component's priority for sorting.
  ///
  /// You must provide the parent so that it can be handed to the children that
  /// will be added.
  static ComponentSet createDefault(
    Component parent,
  ) {
    return ComponentSet(
      Comparing.on<Component>((c) => c.priority),
      parent,
    );
  }
}
