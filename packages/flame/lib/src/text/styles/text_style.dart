import 'dart:ui';

import 'package:flame/src/text/styles/style.dart';
import 'package:meta/meta.dart';

@immutable
class TextStyle extends Style {
  const TextStyle({
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

  TextStyle cloneWith({
    Color? color,
    String? fontFamily,
    double? fontSize,
    double? fontScale,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
  }) {
    return TextStyle(
      color: color ?? this.color,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      fontScale: fontScale ?? this.fontScale,
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle ?? this.fontStyle,
      letterSpacing: letterSpacing ?? this.letterSpacing,
    );
  }

  TextStyle mergeWith(TextStyle other) {
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
}
