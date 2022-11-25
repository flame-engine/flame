import 'dart:collection';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// A [ChangeNotifier] that notifies its listeners when a [Component] is
/// added or removed, or updated. The meaning of an updated component
/// will vary depending on the component implementation, this is something
/// defined and executed by the component itself.
///
/// For example, in a Player component, that holds a health variable
/// you may want to notify changes when that variable has changed.
class ComponentsNotifier<T extends Component> extends ChangeNotifier {
  ComponentsNotifier(List<T> initial) : _components = initial;

  final List<T> _components;

  /// The list of components.
  List<T> get components => UnmodifiableListView(_components);

  /// Returns a single element of the components on the game.
  ///
  /// Returns null if there is no component.
  T? get single {
    if (_components.isNotEmpty) {
      return _components.first;
    }
    return null;
  }

  @internal
  bool applicable(Component component) => component is T;

  @internal
  void add(T component) {
    _components.add(component);
    notifyListeners();
  }

  @internal
  void remove(T component) {
    _components.remove(component);
    notifyListeners();
  }

  @internal
  void notify() => notifyListeners();
}
