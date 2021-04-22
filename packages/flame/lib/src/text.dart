import 'dart:ui';

import 'package:flutter/material.dart' as material;

import 'anchor.dart';
import 'components/text_component.dart';
import 'extensions/size.dart';
import 'extensions/vector2.dart';
import 'memory_cache.dart';

abstract class TextRenderer {
  /// Renders a given [text] in a given position [position] using the provided [canvas] and [anchor].
  ///
  /// Renders it in the given position, considering the [anchor] specified.
  /// For example, if [Anchor.center] is specified, it's going to be drawn centered around [position].
  ///
  /// Example usage (Using TextPaint implementation):
  ///
  ///     const TextPaint config = TextPaint(fontSize: 48.0, fontFamily: 'Awesome Font');
  ///     config.render(canvas, Vector2(size.x - 10, size.y - 10, anchor: Anchor.bottomRight);
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
}

/// A Text Config contains all typographical information required to render texts; i.e., font size and color, family, etc.
///
/// It does not hold information regarding the position of the text to be render neither the text itself (the string).
/// To hold all those information, use the Text component.
///
/// It is used by [TextComponent].
class TextPaint extends TextRenderer {
  /// The font size to be used, in points.
  final double fontSize;

  /// The font color to be used.
  ///
  /// Dart's [Color] class is just a plain wrapper on top of ARGB color (0xAARRGGBB).
  /// For example,
  ///
  ///     const TextPaint config = TextPaint(color: const Color(0xFF00FF00)); // green
  ///
  /// You can also use your Palette class to access colors used in your game.
  final Color color;

  /// The font family to be used. You can use available by default fonts for your platform (like Arial), or you can add custom fonts.
  ///
  /// To add custom fonts, add the following code to your pubspec.yaml file:
  ///
  ///     flutter:
  ///       fonts:
  ///         - family: 5x5
  ///           fonts:
  ///             - asset: assets/fonts/5x5_pixel.ttf
  ///
  /// In this example we are adding a font family that's being named '5x5' provided in the specified ttf file.
  /// You must provide the full path of the ttf file (from root); you should put it into your assets folder, and preferably inside a fonts folder.
  /// You don't need to add this together with the other assets on the flutter/assets bit.
  /// The name you choose for the font family can be any name (it's not inside the TTF file and the filename doesn't need to match).
  final String fontFamily;

  /// The [TextAlign] to be used when creating the [material.TextPainter].
  ///
  /// Beware: it's recommended to leave this with the default value of [TextAlign.left].
  /// Use the anchor parameter to [render] to specify a proper relative position.
  final TextAlign textAlign;

  /// The direction to render this text (left to right or right to left).
  ///
  /// Normally, leave this as is for most languages.
  /// For proper fonts of languages like Hebrew or Arabic, replace this with [TextDirection.rtl].
  final TextDirection textDirection;

  /// The height of line, as a multiple of font size.
  final double? lineHeight;

  final MemoryCache<String, material.TextPainter> _textPainterCache =
      MemoryCache();

  /// Creates a constant [TextPaint] with sensible defaults.
  ///
  /// Every parameter can be specified.
  TextPaint({
    this.fontSize = 24.0,
    this.color = const Color(0xFF000000),
    this.fontFamily = 'Arial',
    this.textAlign = TextAlign.left,
    this.textDirection = TextDirection.ltr,
    this.lineHeight,
  });

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

  /// Returns a [material.TextPainter] that allows for text rendering and size measuring.
  ///
  /// A [material.TextPainter] has three important properties: paint, width and height (or size).
  ///
  /// Example usage:
  ///
  ///     const TextPaint config = TextPaint(fontSize: 48.0, fontFamily: 'Awesome Font');
  ///     final tp = config.toTextPainter('Score: $score');
  ///     tp.paint(c, Offset(size.width - p.width - 10, size.height - p.height - 10));
  ///
  /// However, you probably want to use the [render] method witch already renders for you considering the anchor.
  /// That way, you don't need to perform the math for yourself.
  material.TextPainter toTextPainter(String text) {
    if (!_textPainterCache.containsKey(text)) {
      final style = material.TextStyle(
        color: color,
        fontSize: fontSize,
        fontFamily: fontFamily,
        height: lineHeight,
      );
      final span = material.TextSpan(
        style: style,
        text: text,
      );
      final tp = material.TextPainter(
        text: span,
        textAlign: textAlign,
        textDirection: textDirection,
      );
      tp.layout();

      _textPainterCache.setValue(text, tp);
    }
    return _textPainterCache.getValue(text)!;
  }

  /// Creates a new [TextPaint] changing only the [fontSize].
  ///
  /// This does not change the original (as it's immutable).
  TextPaint withFontSize(double fontSize) {
    return TextPaint(
      fontSize: fontSize,
      color: color,
      fontFamily: fontFamily,
      textAlign: textAlign,
      textDirection: textDirection,
    );
  }

  /// Creates a new [TextPaint] changing only the [color].
  ///
  /// This does not change the original (as it's immutable).
  TextPaint withColor(Color color) {
    return TextPaint(
      fontSize: fontSize,
      color: color,
      fontFamily: fontFamily,
      textAlign: textAlign,
      textDirection: textDirection,
    );
  }

  /// Creates a new [TextPaint] changing only the [fontFamily].
  ///
  /// This does not change the original (as it's immutable).
  TextPaint withFontFamily(String fontFamily) {
    return TextPaint(
      fontSize: fontSize,
      color: color,
      fontFamily: fontFamily,
      textAlign: textAlign,
      textDirection: textDirection,
    );
  }

  /// Creates a new [TextPaint] changing only the [textAlign].
  ///
  /// This does not change the original (as it's immutable).
  TextPaint withTextAlign(TextAlign textAlign) {
    return TextPaint(
      fontSize: fontSize,
      color: color,
      fontFamily: fontFamily,
      textAlign: textAlign,
      textDirection: textDirection,
    );
  }

  /// Creates a new [TextPaint] changing only the [textDirection].
  ///
  /// This does not change the original (as it's immutable).
  TextPaint withTextDirection(TextDirection textDirection) {
    return TextPaint(
      fontSize: fontSize,
      color: color,
      fontFamily: fontFamily,
      textAlign: textAlign,
      textDirection: textDirection,
    );
  }
}
