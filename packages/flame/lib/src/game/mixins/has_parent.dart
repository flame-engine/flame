import 'package:flutter/material.dart';

import '../../../components.dart';

/// A mixin that ensures a parent is of the given type [T].
mixin HasParent<T extends Component> on Component {
  @override
  T get parent => super.parent! as T;

  @override
  @mustCallSuper
  Future<void>? addToParent(Component parent) {
    assert(parent is T, 'Parent must be of type $T');
    return super.addToParent(parent);
  }
}
