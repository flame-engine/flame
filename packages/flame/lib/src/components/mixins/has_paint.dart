import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/src/palette.dart';

/// Adds a collection of paints and paint layers to a component
///
/// Component will always have a main Paint that can be accessed
/// by the [paint] attribute and other paints can be manipulated/accessed
/// using [getPaint], [setPaint] and [deletePaint] by a paintId of generic type
/// [T], that can be omitted if the component only has one paint.
/// [paintLayers] paints should be drawn in list order during the render. The
/// main Paint is the first element.
mixin HasPaint<T extends Object> on Component {
  final Map<T, Paint> _paints = {};
  final _emptyPaint = BasicPalette.white.paint();

  /// List of paints to use (in order) during render.
  List<Paint> paintLayers = [BasicPalette.white.paint()];

  /// Main paint. The first paint in the [paintLayers] list.
  Paint get paint => paintLayers.isEmpty ? _emptyPaint : paintLayers[0];
  set paint(Paint newPaint) => paintLayers[0] = newPaint;

  /// Gets a paint from the collection.
  ///
  /// Returns the main paint if no [paintId] is provided.
  Paint getPaint([T? paintId]) {
    if (paintId == null) {
      return paint;
    }

    final _paint = _paints[paintId];

    if (_paint == null) {
      throw ArgumentError('No Paint found for $paintId');
    }

    return _paint;
  }

  /// Sets a paint on the collection.
  /// If [updatePaintLayers] then also adds a new [paintId], or replaces
  /// matching paints, in [paintLayers].
  void setPaint(T paintId, Paint paint, {bool updatePaintLayers = true}) {
    if (updatePaintLayers) {
      final oldPaint = _paints[paintId];
      if (oldPaint == paint) {
        return; // nothing to do
      }
      if (oldPaint == null) {
        // add new paint to paintLayers
        paintLayers.add(paint);
      } else {
        // replace all oldPaint references in paintLayers with new paint
        for (var i = 0; i < paintLayers.length; ++i) {
          if (paintLayers[i] == oldPaint) {
            paintLayers[i] = paint;
          }
        }
      }
    }

    _paints[paintId] = paint;
  }

  /// Removes a paint from the collection.
  /// If [updatePaintLayers] then also removes matching paints from
  /// [paintLayers].
  void deletePaint(T paintId, {bool updatePaintLayers = true}) {
    final removedPaint = _paints.remove(paintId);
    if (updatePaintLayers) {
      paintLayers.removeWhere((element) => element == removedPaint);
    }
  }

  /// Adds [paintId] to paintLayers.
  /// Shortcut for paintLayers.add(getPaint(paintId)).
  void addPaintLayer(T paintId) {
    final _paint = _paints[paintId];

    if (_paint == null) {
      throw ArgumentError('No Paint found for $paintId');
    }

    paintLayers.add(_paint);
  }

  /// Removes all [paintId] from paintLayers.
  void removePaintIdFromLayers(T paintId) {
    final _paint = _paints[paintId];

    if (_paint == null) {
      throw ArgumentError('No Paint found for $paintId');
    }

    paintLayers.removeWhere((element) => element == _paint);
  }

  /// Sets paintLayers from [paintIds] list.
  void setPaintLayers(List<T> paintIds) {
    paintLayers = paintIds.map(getPaint).toList();
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

    setColor(getPaint(paintId).color.withOpacity(opacity), paintId: paintId);
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

    setColor(getPaint(paintId).color.withAlpha(alpha), paintId: paintId);
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
