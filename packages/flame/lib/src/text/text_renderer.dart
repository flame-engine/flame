import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

import '../anchor.dart';
import 'text_paint.dart';

/// [TextRenderer] is the abstract API for drawing text.
///
/// A text renderer usually embodies a particular style for rendering text, such
/// as font-family, color, size, and so on. At the same time, a text renderer
/// is not tied to a specific string -- it can render any text fragment that
/// you give it.
///
/// A text renderer object has two functions: to measure the size of a text
/// string that it will have when rendered, and to actually render that string
/// onto a canvas.
///
/// The following text renderers are included in Flame:
///  - [TextPaint] which uses the standard Flutter's `TextPainter`;
abstract class TextRenderer {
  /// Renders [text] on the [canvas] at a given [position].
  ///
  /// For example, if [Anchor.center] is specified, it's going to be drawn
  /// centered around [position].
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
