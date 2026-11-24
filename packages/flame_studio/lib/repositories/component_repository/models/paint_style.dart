/// How a paint is applied to a shape.
///
/// Mirrors `PaintingStyle` from `dart:ui` without depending on Flutter.
enum PaintStyle() {
  /// Fills the shape.
  fill,

  /// Draws only the outline of the shape.
  stroke;

  /// Returns the style called [name], or `null` if there is none.
  static PaintStyle? fromName(Object? name) {
    for (final style in values) {
      if (style.name == name) {
        return style;
      }
    }
    return null;
  }
}
