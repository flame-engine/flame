import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/src/palette.dart';

/// Adds a collection of paints to a component
///
/// Component will always have a main Paint that can be accessed
/// by the [paint] attribute and other paints can be manipulated/accessed
/// using [getPaint], [setPaint] and [deletePaint] by a paintId of generic type
/// [T], that can be omitted if the component only have one paint.
mixin HasPaint<T extends Object> on Component {
  final Map<T, Paint> _paints = {};

  Paint paint = BasicPalette.white.paint();

  void _assertGenerics() {
    assert(T != Object, 'A generics type is missing on the HasPaint mixin');
  }

  /// Gets a paint from the collection.
  ///
  /// Returns the main paint if no [paintId] is provided.
  Paint getPaint([T? paintId]) {
    if (paintId == null) {
      return paint;
    }

    _assertGenerics();
    final _paint = _paints[paintId];

    if (_paint == null) {
      throw ArgumentError('No Paint found for $paintId');
    }

    return _paint;
  }

  /// Sets a paint on the collection.
  void setPaint(T paintId, Paint paint) {
    _assertGenerics();
    _paints[paintId] = paint;
  }

  /// Removes a paint from the collection.
  void deletePaint(T paintId) {
    _assertGenerics();
    _paints.remove(paintId);
  }

  /// Manipulate the paint to make it fully transparent.
  void makeTransparent({T? paintId}) {
    setOpacity(0, paintId: paintId);
  }

  /// Manipulate the paint to make it fully opaque.
  void makeOpaque({T? paintId}) {
    setOpacity(1, paintId: paintId);
  }

  /// Changes the opacity of the paint.
  void setOpacity(double opacity, {T? paintId}) {
    if (opacity < 0 || opacity > 1) {
      throw ArgumentError('Opacity needs to be between 0 and 1');
    }

    getPaint(paintId).color = paint.color.withOpacity(opacity);
  }

  /// Returns the current opacity.
  double getOpacity({T? paintId}) {
    return getPaint(paintId).color.opacity;
  }

  /// Changes the opacity of the paint.
  void setAlpha(int alpha, {T? paintId}) {
    if (alpha < 0 || alpha > 255) {
      throw ArgumentError('Alpha needs to be between 0 and 255');
    }

    getPaint(paintId).color = paint.color.withAlpha(alpha);
  }

  /// Returns the current opacity.
  int getAlpha({T? paintId}) {
    return getPaint(paintId).color.alpha;
  }

  /// Shortcut for changing the color of the paint.
  void setColor(Color color, {T? paintId}) {
    getPaint(paintId).color = color;
  }

  /// Applies a color filter to the paint which will make
  /// things rendered with the paint looking like it was
  /// tinted with the given color.
  void tint(Color color, {T? paintId}) {
    getPaint(paintId).colorFilter = ColorFilter.mode(color, BlendMode.srcATop);
  }
}
