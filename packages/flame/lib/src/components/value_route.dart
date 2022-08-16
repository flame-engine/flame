import 'dart:async';

import 'package:flame/src/components/route.dart';
import 'package:meta/meta.dart';

abstract class ValueRoute<T> extends Route {
  ValueRoute({required T value, super.transparent})
      : _defaultValue = value,
        _completer = Completer<T>(),
        super(null);

  final T _defaultValue;
  final Completer<T> _completer;

  /// Future that will complete when this route is popped from the stack.
  Future<T> get future => _completer.future;

  @protected
  void completeWith(T value) {
    _completer.complete(value);
    parent.popRoute(this);
  }

  @protected
  void complete() => completeWith(_defaultValue);

  @mustCallSuper
  @override
  void didPop(Route previousRoute) {
    if (!_completer.isCompleted) {
      _completer.complete(_defaultValue);
    }
  }
}
