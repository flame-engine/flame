import 'dart:ui';

import 'package:flame/src/rendering/paint_decorator.dart';
import 'package:flame/src/rendering/rotate3d_decorator.dart';
import 'package:flame/src/rendering/shadow3d_decorator.dart';
import 'package:flame/src/rendering/transform2d_decorator.dart';
import 'package:meta/meta.dart';

/// [Decorator] is an abstract class that encapsulates a particular visual
/// effect that should apply to drawing commands wrapped by this class.
///
/// The simplest way to apply a [Decorator] to a component is to override its
/// `renderTree` method like this:
/// ```dart
/// @override
/// void renderTree(Canvas canvas) {
///   decorator.applyChain(super.renderTree, canvas);
/// }
/// ```
///
/// Decorators have ability to form a chain, where multiple decorators can be
/// applied in a sequence. This chain is essentially a unary tree, or a linked
/// list: each decorator knows only about the next decorator on the chain.
///
/// The following implementations are available:
/// - [PaintDecorator]
/// - [Rotate3DDecorator]
/// - [Shadow3DDecorator]
/// - [Transform2DDecorator]
class Decorator {
  /// The next decorator in the chain, or null if there is none.
  Decorator? _next;

  /// Applies this and all subsequent decorators if any.
  ///
  /// This method is the main method through which the decorator is applied.
  void applyChain(void Function(Canvas) draw, Canvas canvas) {
    apply(
      _next == null
          ? draw
          : (nextCanvas) => _next!.applyChain(draw, nextCanvas),
      canvas,
    );
  }

  /// Applies visual effect while [draw]ing on the [canvas].
  ///
  /// The default implementation is a no-op; all other non-trivial decorators
  /// transform the canvas before drawing, or perform some other adjustments.
  ///
  /// This method must be implemented by the subclasses, but it is not available
  /// to external users: use [applyChain] instead.
  @protected
  void apply(void Function(Canvas) draw, Canvas canvas) {
    draw(canvas);
  }

  //#region Decorator chain functionality

  bool get isLastDecorator => _next == null;

  /// Adds a new decorator onto the chain of decorators
  void addLast(Decorator? decorator) {
    if (decorator != null) {
      if (_next == null) {
        _next = decorator;
      } else {
        _next!.addLast(decorator);
      }
    }
  }

  /// Removes the last decorator from the chain of decorators
  void removeLast() {
    if (isLastDecorator) {
      return;
    }
    if (_next!.isLastDecorator) {
      _next = null;
    } else {
      _next!.removeLast();
    }
  }

  void replaceLast(Decorator? decorator) {
    if (decorator == null) {
      removeLast();
    } else if (isLastDecorator || _next!.isLastDecorator) {
      _next = decorator;
    } else {
      _next!.replaceLast(decorator);
    }
  }

  //#endregion
}
