import 'package:flame/src/text/renderers/text_paint.dart';
import 'package:flame/src/text/renderers/text_renderer.dart';
import 'package:flame/src/text/styles/style.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

@immutable
class FlameTextStyle extends Style {
  FlameTextStyle({
    this.color,
    this.fontFamily,
    this.fontSize,
    this.fontScale,
    this.fontWeight,
    this.fontStyle,
    this.letterSpacing,
  });

  final Color? color;
  final String? fontFamily;
  final double? fontSize;
  final double? fontScale;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final double? letterSpacing;

  late final TextRenderer renderer = asTextRenderer();

  @override
  FlameTextStyle copyWith(FlameTextStyle other) {
    return FlameTextStyle(
      color: color ?? other.color,
      fontFamily: fontFamily ?? other.fontFamily,
      fontSize: fontSize ?? other.fontSize,
      fontScale: fontScale ?? other.fontScale,
      fontWeight: fontWeight ?? other.fontWeight,
      fontStyle: fontStyle ?? other.fontStyle,
      letterSpacing: letterSpacing ?? other.letterSpacing,
    );
  }

  @internal
  TextPaint asTextRenderer() {
    return TextPaint(
      style: TextStyle(
        color: color,
        fontFamily: fontFamily,
        fontSize: fontSize! * (fontScale ?? 1.0),
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
      ),
    );
  }
}
