import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// A mixin that ensures a parent is of the given type [T].
mixin ParentIsA<T extends Component> on Component {
  @override
  T get parent => super.parent! as T;

  @override
  @mustCallSuper
  void onMount() {
    assert(super.parent is T, 'Parent must be of type $T');
    super.onMount();
  }
}
