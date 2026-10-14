import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

/// The paints of a path imported from an SVG file: its [fill] and its
/// [stroke], each of which may be missing.
@immutable
class VectorPaint {
  /// The fill component of the SVG style.
  final ui.Paint? fill;

  /// The stroke component of the SVG style.
  final ui.Paint? stroke;

  /// Create from the given [fill] and [stroke].
  const VectorPaint({this.fill, this.stroke});

  /// Create from the given [ui.Paint], which can only result in either
  /// [fill] or [stroke] being present (not both).
  VectorPaint.paint(ui.Paint paint)
    : fill = paint.style == .fill ? paint : null,
      stroke = paint.style == .stroke ? paint : null;

  /// Return either the [fill] or [stroke] paint object.
  ui.Paint? get paint => fill ?? stroke;

  /// Return a list of [ui.Paint], with at most two elements, [fill] and
  /// [stroke].
  List<ui.Paint>? get paintLayers {
    final paints = [?fill, ?stroke];
    return paints.isNotEmpty ? paints : null;
  }

  /// Whether the [fill] component is present.
  bool get isFilled => fill != null;

  /// Whether the [stroke] component is present.
  bool get isStroked => stroke != null;

  @override
  String toString() {
    var result = 'VectorPaint(';
    if (fill != null) {
      result += 'fill: $fill';
    }
    if (stroke != null) {
      if (fill != null) {
        result += ', ';
      }
      result += 'stroke: $stroke';
    }
    return '$result)';
  }

  @override
  int get hashCode => Object.hash(fill, stroke);

  @override
  bool operator ==(Object other) {
    if (other is VectorPaint) {
      return fill == other.fill && stroke == other.stroke;
    }
    return false;
  }
}
