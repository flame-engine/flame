import 'dart:ui';

import 'package:flame/src/text/formatters/text_formatter.dart';
import 'package:flame/src/text/formatters/text_painter_text_formatter.dart';
import 'package:flame/src/text/styles/style.dart';
import 'package:flutter/rendering.dart' as flutter;
import 'package:meta/meta.dart';

@immutable
class TextStyle extends Style {
  TextStyle({
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

  late final TextFormatter formatter = asTextFormatter();

  @override
  TextStyle copyWith(TextStyle other) {
    return TextStyle(
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
  TextPainterTextFormatter asTextFormatter() {
    return TextPainterTextFormatter(
      style: flutter.TextStyle(
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
