import 'package:ordered_set/comparing.dart';
import 'package:ordered_set/queryable_ordered_set.dart';

import '../../components.dart';

class ComponentSet extends QueryableOrderedSet<Component> {
  /// Components to be added on the next update.
  ///
  /// The component list is only changed at the start of each update to avoid
  /// concurrency issues.
  final List<Component> _addLater = [];

  /// Components to be removed on the next update.
  ///
  /// The component list is only changed at the start of each update to avoid
  /// concurrency issues.
  final Set<Component> _removeLater = {};

  ComponentSet(int Function(Component e1, Component e2)? compare)
      : super(compare);

  @override
  bool add(Component c) {
    _addLater.add(c);
    return true;
  }

  /// Prepares and registers a list of components to be added on the next game tick
  @override
  int addAll(Iterable<Component> components) {
    components.forEach(add);
    return components.length;
  }

  /// Marks a component to be removed from the components list on the next game tick
  @override
  bool remove(Component c) {
    _removeLater.add(c);
    return true;
  }

  /// Marks a list of components to be removed from the components list on the next game tick
  void removeAll(Iterable<Component> components) {
    _removeLater.addAll(components);
  }

  /// Marks all existing components to be removed from the components list on the next game tick
  @override
  void clear() {
    _removeLater.addAll(this);
  }

  Iterable<Component> reversed() {
    return toList().reversed;
  }

  void updateComponentList() {
    _removeLater.addAll(where((c) => c.shouldRemove));
    _removeLater.forEach((c) {
      c.onRemove();
      super.remove(c);
    });
    _removeLater.clear();

    if (_addLater.isNotEmpty) {
      final addNow = _addLater.toList(growable: false);
      _addLater.clear();
      addNow.forEach((c) {
        super.add(c);
        c.onMount();
      });
    }
  }

  static ComponentSet createDefault() {
    return ComponentSet(Comparing.on<Component>((c) => c.priority));
  }
}
