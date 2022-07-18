import 'dart:ui';

import 'package:flame/src/rendering/paint_decorator.dart';
import 'package:flame/src/rendering/rotate3d_decorator.dart';

/// [Decorator] is an abstract class that encapsulates a particular visual
/// effect that should apply to drawing commands wrapped by this class.
///
/// The simplest way to apply a [Decorator] to a component is to override its
/// `renderTree` method like this:
/// ```dart
/// @override
/// void renderTree(Canvas canvas) {
///   decorator.apply(super.renderTree, canvas);
/// }
/// ```
///
/// The following implementations are available:
/// - [PaintDecorator]
/// - [Rotate3DDecorator]
abstract class Decorator {
  /// Applies visual effect while [draw]ing on the [canvas].
  ///
  /// A no-op decorator would simply call `draw(canvas)`. Any other non-trivial
  /// decorator can transform the canvas before drawing, or perform any other
  /// adjustment.
  void apply(void Function(Canvas) draw, Canvas canvas);
}
