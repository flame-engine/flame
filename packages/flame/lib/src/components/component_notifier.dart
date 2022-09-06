import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// A [ChangeNotifier] that notifies its listeners when a [Component] is
/// added or removed, or updated.
class ComponentNotifier<T extends Component> extends ChangeNotifier {
  ComponentNotifier(List<T> initial) : _components = initial;

  final List<T> _components;

  /// The list of components.
  List<T> get components => _components;

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
  void update() => notifyListeners();
}
