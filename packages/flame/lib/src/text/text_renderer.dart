import 'dart:ui';

import 'package:flame/src/anchor.dart';
import 'package:flame/text.dart';
import 'package:vector_math/vector_math_64.dart';

/// [TextRenderer] is the most basic API for drawing text.
///
/// A text renderer contains a [formatter] that embodies a particular style
/// for rendering text, such as font-family, color, size, and so on.
/// At the same time, nor the text renderer or the [formatter] are tied to a
/// specific string -- it can render any text fragment that you give it.
///
/// A text renderer object has two functions: to measure the size of a text
/// string that it will have when rendered, and to actually render that string
/// onto a canvas.
///
/// [TextRenderer] is a low-level API that may be somewhat inconvenient to use
/// directly. Instead, consider using components such as TextComponent or
/// TextBoxComponent.
///
/// See [TextFormatter] for more information about existing options.
class TextRenderer<T extends TextFormatter> {
  TextRenderer(this.formatter);

  final T formatter;

  TextElement format(String text) {
    return formatter.format(text);
  }

  LineMetrics getLineMetrics(String text) {
    return format(text).metrics;
  }

  void render(
    Canvas canvas,
    String text,
    Vector2 position, {
    Anchor anchor = Anchor.topLeft,
  }) {
    final element = format(text);
    renderElement(canvas, element, position, anchor: anchor);
  }

  void renderElement(
    Canvas canvas,
    TextElement element,
    Vector2 position, {
    Anchor anchor = Anchor.topLeft,
  }) {
    final box = element.metrics;
    element.translate(
      position.x - box.width * anchor.x,
      position.y - box.height * anchor.y - box.top,
    );
    element.render(canvas);
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
