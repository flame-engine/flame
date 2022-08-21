import 'dart:ui';

import 'package:flame/src/components/component.dart';
import 'package:flame/src/rendering/decorator.dart';

/// [HasDecorator] mixin adds a nullable [decorator] field to a Component. If
/// this field is set, it will apply the visual effect encapsulated in this
/// [Decorator] to the component. If the field is not set, then the component
/// will be rendered normally.
///
/// Note that the decorator only affects visual rendering of a component, but
/// not its perceived size or shape from the point of view of tap events.
///
/// See also:
///  - [Decorator] class for the list of available decorators.
mixin HasDecorator on Component {
  Decorator? decorator;

  @override
  void renderTree(Canvas canvas) {
    if (decorator == null) {
      super.renderTree(canvas);
    } else {
      decorator!.applyChain(super.renderTree, canvas);
    }
  }
}
