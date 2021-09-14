import 'dart:ui';

import '../../../components.dart';
import '../../palette.dart';

/// Adds a collection of paints to a component
///
/// Component will always have a main Paint that can be accessed
/// by the [paint] attribute and other paints can be manipulated/accessed
/// using [getPaint], [setPaint] and [deletePaint] by a paintId of generic type [T], that can be omited if the component only have one paint.
mixin HasPaint<T extends Object> on Component {
  final Map<T, Paint> _paints = {};

  Paint paint = BasicPalette.white.paint();

  void _asserGenerics() {
    assert(
      T != Object,
      'When using the paint collection, component should declare a generic type',
    );
  }

  /// Gets a paint from the collection.
  ///
  /// Returns the main paint if no [paintId] is provided.
  Paint getPaint([T? paintId]) {
    if (paintId == null) {
      return paint;
    }

    _asserGenerics();
    final _paint = _paints[paintId];

    if (_paint == null) {
      throw ArgumentError('No Paint found for $paintId');
    }

    return _paint;
  }

  /// Sets a paint on the collection
  void setPaint(T paintId, Paint paint) {
    _asserGenerics();
    _paints[paintId] = paint;
  }

  /// Removes a paint from the collection
  void deletePaint(T paintId) {
    _asserGenerics();
    _paints.remove(paintId);
  }

  /// Manipulate the paint to make it fully transparent
  void makeTransparent({T? paintId}) {
    setOpacity(0, paintId: paintId);
  }

  /// Manipulate the paint to make it fully opaque
  void makeOpaque({T? paintId}) {
    setOpacity(1, paintId: paintId);
  }

  /// Changes the opacity of the paint
  void setOpacity(double opacity, {T? paintId}) {
    if (opacity < 0 || opacity > 1) {
      throw ArgumentError('Opacity needs to be between 0 and 1');
    }

    getPaint(paintId).color = paint.color.withOpacity(opacity);
  }

  /// Returns the current opacity
  double getOpacity({T? paintId}) {
    return getPaint(paintId).color.opacity;
  }

  /// Shortcut for changing the color of the paint
  void setColor(Color color, {T? paintId}) {
    getPaint(paintId).color = color;
  }

  /// Applies a color filter to the paint which will make
  /// things rendered with the paint looking like it was
  // tinted with the given color
  void tint(Color color, {T? paintId}) {
    getPaint(paintId).colorFilter = ColorFilter.mode(color, BlendMode.multiply);
  }
}
