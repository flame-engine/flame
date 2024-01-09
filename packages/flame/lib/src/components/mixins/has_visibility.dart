import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// A mixin that allows a component visibility to be toggled
/// without removing it from the tree. Visibility affects
/// the component and all it's children/descendants.
///
/// Set [isVisible] to false to prevent the component and all
/// it's children from being rendered.
///
/// The component will still respond as if it is on the tree,
/// including lifecycle and other events, but will simply
/// not render itself or it's children.
///
/// If you are adding a custom implementation of the
/// [renderTree] method, make sure to wrap your render code
/// in a conditional. i.e.:
/// ```
/// if (isVisible) {
///     // Custom render code here
/// }
/// ```
mixin HasVisibility on Component {
  bool isVisible = true;

  @override
  void renderTree(Canvas canvas) {
    if (isVisible) {
      super.renderTree(canvas);
    }
  }
}
