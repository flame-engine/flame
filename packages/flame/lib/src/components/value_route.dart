import 'dart:async';

import 'package:flame/src/components/route.dart';
import 'package:flame/src/components/router_component.dart';
import 'package:meta/meta.dart';

/// [ValueRoute] is a special route that "returns a value" when popped.
///
/// This class requires to be derived, and therefore it doesn't have the regular
/// `.builder` function -- override the [build] method instead.
///
/// This route is used in conjunction with [RouterComponent.pushAndWait]. The
/// return value must be supplied using the [completeWith] method from the
/// derived class. Usually this method will be invoked by the component
/// constructed in the [build] method.
///
/// If the route is popped without invoking [completeWith], then the
/// [_defaultValue] will be used.
abstract class ValueRoute<T> extends Route {
  ValueRoute({required T value, super.transparent})
      : _defaultValue = value,
        _completer = Completer<T>(),
        super(null);

  final T _defaultValue;
  final Completer<T> _completer;

  /// Future that will complete when this route is popped from the stack.
  Future<T> get future => _completer.future;

  void completeWith(T value) {
    _completer.complete(value);
    parent.popRoute(this);
  }

  void complete() => completeWith(_defaultValue);

  @mustCallSuper
  @override
  void didPop(Route previousRoute) {
    if (!_completer.isCompleted) {
      _completer.complete(_defaultValue);
    }
  }
}
