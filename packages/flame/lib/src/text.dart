import 'package:flutter/material.dart';

import 'anchor.dart';
import 'components/cache/memory_cache.dart';
import 'components/text_component.dart';
import 'extensions/size.dart';
import 'extensions/vector2.dart';

/// [TextRenderer] is the abstract API that Flame uses for rendering text.
/// This class can be extended to provide another implementation of text
/// rendering in the engine.
///
/// See [TextPaint] for the default implementation offered by Flame
abstract class TextRenderer {
  /// A registry containing default providers for every [TextRenderer] subclass;
  /// used by [createDefault] to create default parameter values.
  ///
  /// If you add a new [TextRenderer] child, you can register it by adding it,
  /// together with a provider lambda, to this map.
  static Map<Type, TextRenderer Function()> defaultRenderersRegistry = {
    TextRenderer: () => TextPaint(),
    TextPaint: () => TextPaint(),
  };

  final TextDirection textDirection;

  TextRenderer({TextDirection? textDirection})
      : textDirection = textDirection ?? TextDirection.ltr;

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

  /// Given a generic type [T], creates a default renderer of that type.
  static T createDefault<T extends TextRenderer>() {
    final creator = defaultRenderersRegistry[T];
    if (creator != null) {
      return creator() as T;
    } else {
      throw 'Unknown implementation of TextRenderer: $T. Please register it '
          'under [defaultCreatorsRegistry].';
    }
  }
}

/// It does not hold information regarding the position of the text to be
/// rendered, nor does it contain the text itself (the string).
/// To use that information, use the [TextComponent], which uses [TextPaint].
class TextPaint extends TextRenderer {
  static const TextStyle defaultTextStyle = TextStyle(
    color: Colors.white,
    fontFamily: 'Arial',
    fontSize: 24,
  );

  final MemoryCache<String, TextPainter> _textPainterCache = MemoryCache();
  final TextStyle style;

  TextPaint({TextStyle? style, TextDirection? textDirection})
      : style = style ?? defaultTextStyle,
        super(
          textDirection: textDirection,
        );

  @override
  void render(
    Canvas canvas,
    String text,
    Vector2 p, {
    Anchor anchor = Anchor.topLeft,
  }) {
    final tp = toTextPainter(text);
    final translatedPosition = anchor.translate(p, tp.size.toVector2());
    tp.paint(canvas, translatedPosition.toOffset());
  }

  @override
  double measureTextWidth(String text) {
    return toTextPainter(text).width;
  }

  @override
  double measureTextHeight(String text) {
    return toTextPainter(text).height;
  }

  /// Returns a [TextPainter] that allows for text rendering and size
  /// measuring.
  ///
  /// A [TextPainter] has three important properties: paint, width and
  /// height (or size).
  ///
  /// Example usage:
  ///
  ///   const TextPaint config = TextPaint(fontSize: 48.0, fontFamily: 'Arial');
  ///   final tp = config.toTextPainter('Score: $score');
  ///   tp.paint(canvas, const Offset(10, 10));
  ///
  /// However, you probably want to use the [render] method which already
  /// takes the anchor into consideration.
  /// That way, you don't need to perform the math for that yourself.
  TextPainter toTextPainter(String text) {
    if (!_textPainterCache.containsKey(text)) {
      final span = TextSpan(
        style: style,
        text: text,
      );
      final tp = TextPainter(
        text: span,
        textDirection: textDirection,
      );
      tp.layout();

      _textPainterCache.setValue(text, tp);
    }
    return _textPainterCache.getValue(text)!;
  }

  TextPaint copyWith(
    TextStyle Function(TextStyle) transform, {
    TextDirection? textDirection,
  }) {
    return TextPaint(style: transform(style), textDirection: textDirection);
  }
}
