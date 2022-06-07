import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// A mixin that ensures an ancestor is of the given type [T].
///
/// Exposes an [ancestor] field of the given type [T].
mixin HasAncestor<T extends Component> on Component {
  /// A reference to an ancestor in the component tree.
  T get ancestor => _ancestor!;
  T? _ancestor;

  @override
  @mustCallSuper
  void onMount() {
    if (_ancestor == null) {
      var c = parent;
      while (c != null) {
        if (c is HasAncestor<T>) {
          _ancestor = c.ancestor;
          break;
        } else if (c is T) {
          _ancestor = c;
          break;
        } else {
          c = c.parent;
        }
      }
    }
    assert(
      _ancestor != null,
      'An ancestor must be of type $T in the component tree',
    );

    super.onMount();
  }

  @override
  @mustCallSuper
  void onRemove() {
    super.onRemove();
    _ancestor = null;
  }
}
