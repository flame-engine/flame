import 'dart:ui';

import 'package:flutter/material.dart' as material;

import 'anchor.dart';
import 'components/cache/memory_cache.dart';
import 'components/text_component.dart';
import 'extensions/size.dart';
import 'extensions/vector2.dart';

/// [TextRenderer] is the abstract API that Flame uses for rendering text in its features
/// this class can be extended to provide an implementation of text rendering in the engine.
///
/// See [TextPaint] for the default implementation offered by Flame
abstract class TextRenderer<T extends BaseTextConfig> {
  /// A registry containing default providers for every [TextRenderer] subclass;
  /// used by [createDefault] to create default parameter values.
  ///
  /// If you add a new [TextRenderer] child, you can register it by adding it,
  /// alongisde a provider lambda, to this map.
  static Map<Type, TextRenderer Function()> defaultCreatorsRegistry = {
    TextRenderer: () => TextPaint(),
    TextPaint: () => TextPaint(),
  };

  final T config;

  TextRenderer({required this.config});

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

  /// Creates a new instance of this painter but transforming the [config]
  /// object via the provided lambda.
  TextRenderer<T> copyWith(T Function(T) transform);

  /// Given a generic type [T], creates a default renderer of that type.
  static T createDefault<T extends TextRenderer>() {
    final creator = defaultCreatorsRegistry[T];
    if (creator != null) {
      return creator() as T;
    } else {
      throw 'Unkown implementation of TextRenderer: $T. Please register it under [defaultCreatorsRegistry].';
    }
  }
}

/// A Text Config contains all typographical information required to render texts; i.e., font size, text direction, etc.
abstract class BaseTextConfig {
  /// The font size to be used, in points.
  final double fontSize;

  /// The direction to render this text (left to right or right to left).
  ///
  /// Normally, leave this as is for most languages.
  /// For proper fonts of languages like Hebrew or Arabic, replace this with [TextDirection.rtl].
  final TextDirection textDirection;

  /// The height of line, as a multiple of font size.
  final double? lineHeight;

  const BaseTextConfig({
    this.fontSize = 24.0,
    this.textDirection = TextDirection.ltr,
    this.lineHeight,
  });
}

/// An extension of the BaseTextConfig which includes more configs supported by
/// TextPaint
class TextPaintConfig extends BaseTextConfig {
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

  /// Creates a constant [TextPaint] with sensible defaults.
  ///
  /// Every parameter can be specified.
  const TextPaintConfig({
    this.color = const Color(0xFF000000),
    this.fontFamily = 'Arial',
    double fontSize = 24.0,
    TextDirection textDirection = TextDirection.ltr,
    double? lineHeight,
  }) : super(
          fontSize: fontSize,
          textDirection: textDirection,
          lineHeight: lineHeight,
        );

  /// Creates a new [TextPaintConfig] changing only the [fontSize].
  ///
  /// This does not change the original (as it's immutable).
  TextPaintConfig withFontSize(double fontSize) {
    return TextPaintConfig(
      fontSize: fontSize,
      color: color,
      fontFamily: fontFamily,
      textDirection: textDirection,
    );
  }

  /// Creates a new [TextPaintConfig] changing only the [color].
  ///
  /// This does not change the original (as it's immutable).
  TextPaintConfig withColor(Color color) {
    return TextPaintConfig(
      fontSize: fontSize,
      color: color,
      fontFamily: fontFamily,
      textDirection: textDirection,
    );
  }

  /// Creates a new [TextPaintConfig] changing only the [fontFamily].
  ///
  /// This does not change the original (as it's immutable).
  TextPaintConfig withFontFamily(String fontFamily) {
    return TextPaintConfig(
      fontSize: fontSize,
      color: color,
      fontFamily: fontFamily,
      textDirection: textDirection,
    );
  }

  /// Creates a new [TextPaintConfig] changing only the [textAlign].
  ///
  /// This does not change the original (as it's immutable).
  TextPaintConfig withTextAlign(TextAlign textAlign) {
    return TextPaintConfig(
      fontSize: fontSize,
      color: color,
      fontFamily: fontFamily,
      textDirection: textDirection,
    );
  }

  /// Creates a new [TextPaintConfig] changing only the [textDirection].
  ///
  /// This does not change the original (as it's immutable).
  TextPaintConfig withTextDirection(TextDirection textDirection) {
    return TextPaintConfig(
      fontSize: fontSize,
      color: color,
      fontFamily: fontFamily,
      textDirection: textDirection,
    );
  }
}

/// A Text Config contains all typographical information required to render texts; i.e., font size and color, family, etc.
///
/// It does not hold information regarding the position of the text to be render neither the text itself (the string).
/// To hold all those information, use the Text component.
///
/// It is used by [TextComponent].
class TextPaint extends TextRenderer<TextPaintConfig> {
  final MemoryCache<String, material.TextPainter> _textPainterCache =
      MemoryCache();

  TextPaint({
    TextPaintConfig config = const TextPaintConfig(),
  }) : super(config: config);

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
  /// However, you probably want to use the [render] method which already renders for you considering the anchor.
  /// That way, you don't need to perform the math for yourself.
  material.TextPainter toTextPainter(String text) {
    if (!_textPainterCache.containsKey(text)) {
      final style = material.TextStyle(
        color: config.color,
        fontSize: config.fontSize,
        fontFamily: config.fontFamily,
        height: config.lineHeight,
      );
      final span = material.TextSpan(
        style: style,
        text: text,
      );
      final tp = material.TextPainter(
        text: span,
        textDirection: config.textDirection,
      );
      tp.layout();

      _textPainterCache.setValue(text, tp);
    }
    return _textPainterCache.getValue(text)!;
  }

  @override
  TextPaint copyWith(
    TextPaintConfig Function(TextPaintConfig) transform,
  ) {
    return TextPaint(config: transform(config));
  }
}
