import 'package:flame/text.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

@immutable
class InlineTextStyle extends FlameTextStyle {
  InlineTextStyle({
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
  InlineTextStyle copyWith(InlineTextStyle other) {
    return InlineTextStyle(
      color: other.color ?? color,
      fontFamily: other.fontFamily ?? fontFamily,
      fontSize: other.fontSize ?? fontSize,
      fontScale: other.fontScale ?? fontScale,
      fontWeight: other.fontWeight ?? fontWeight,
      fontStyle: other.fontStyle ?? fontStyle,
      letterSpacing: other.letterSpacing ?? letterSpacing,
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
