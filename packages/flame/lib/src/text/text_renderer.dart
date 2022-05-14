import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

import '../anchor.dart';
import '../text.dart';

/// [TextRenderer] is the abstract API that Flame uses for rendering text.
/// This class can be extended to provide another implementation of text
/// rendering in the engine.
///
/// See [TextPaint] for the default implementation offered by Flame
abstract class TextRenderer {
  /// Renders a given [text] in a given position [position] using the provided
  /// [canvas] and [anchor].
  ///
  /// For example, if [Anchor.center] is specified, it's going to be drawn
  /// centered around [position].
  ///
  /// Example usage (Using TextPaint implementation):
  ///
  ///   const TextStyle style = TextStyle(fontSize: 48.0, fontFamily: 'Arial');
  ///   const TextPaint textPaint = TextPaint(style: style);
  ///   textPaint.render(
  ///     canvas,
  ///     Vector2(size.x - 10, size.y - 10,
  ///     anchor: Anchor.bottomRight,
  ///   );
  void render(
    Canvas canvas,
    String text,
    Vector2 position, {
    Anchor anchor = Anchor.topLeft,
  });

  /// Given a [text] String, returns the width of that [text].
  double measureTextWidth(String text);

  /// Given a [text] String, returns the height of that [text].
  double measureTextHeight(String text);

  /// Given a [text] String, returns a Vector2 with the size of that [text] has.
  Vector2 measureText(String text) {
    return Vector2(
      measureTextWidth(text),
      measureTextHeight(text),
    );
  }

  /// A registry containing default providers for every [TextRenderer] subclass;
  /// used by [createDefault] to create default parameter values.
  ///
  /// If you add a new [TextRenderer] child, you can register it by adding it,
  /// together with a provider lambda, to this map.
  static Map<Type, TextRenderer Function()> defaultRenderersRegistry = {
    TextRenderer: TextPaint.new,
    TextPaint: TextPaint.new,
  };

  /// Given a generic type [T], creates a default renderer of that type.
  static T createDefault<T extends TextRenderer>() {
    final creator = defaultRenderersRegistry[T];
    if (creator != null) {
      return creator() as T;
    } else {
      throw 'Unknown implementation of TextRenderer: $T. Please register it '
          'under [defaultRenderersRegistry].';
    }
  }
}
