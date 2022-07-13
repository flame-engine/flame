import 'package:meta/meta.dart';

abstract class Style<T extends Style<T>> {
  Style? _parent;

  T clone();

  @protected
  T acquire(Style parent) {
    if (_parent == null) {
      _parent = parent;
      return this as T;
    } else {
      final copy = clone();
      copy._parent = parent;
      return copy;
    }
  }
}
