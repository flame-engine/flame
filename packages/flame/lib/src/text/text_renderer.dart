import 'dart:ui';

import 'package:flame/src/anchor.dart';
import 'package:flame/src/components/text_box_component.dart';
import 'package:flame/src/components/text_component.dart';
import 'package:flame/src/text/sprite_font_renderer.dart';
import 'package:flame/src/text/text_paint.dart';
import 'package:vector_math/vector_math_64.dart';

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
/// [TextRenderer] is a low-level API that may be somewhat inconvenient to use
/// directly. Instead, consider using components such as [TextComponent] or
/// [TextBoxComponent].
///
/// The following text renderers are available in Flame:
///  - [TextPaint] which uses the standard Flutter's `TextPainter`;
///  - [SpriteFontRenderer] which uses a spritesheet as a font file;
abstract class TextRenderer {
  /// Compute the dimensions of [text] when rendered.
  Vector2 measureText(String text);

  /// Compute the width of [text] when rendered.
  double measureTextWidth(String text) => measureText(text).x;

  /// Compute the height of [text] when rendered.
  double measureTextHeight(String text) => measureText(text).y;

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
