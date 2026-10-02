import 'package:flame/text.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

/// A [FlameTextStyle] used to style an inline text element.
///
/// Note: the fields on this class are equivalent to the fields on Flutter's
/// [TextStyle] class; check its documentation for more details.
@immutable
// ignore: prefer_const_constructors_in_immutables
class InlineTextStyle({
  final Color? color,
  final String? fontFamily,
  final double? fontSize,
  final double? fontScale,
  final FontWeight? fontWeight,
  final FontStyle? fontStyle,
  final double? letterSpacing,
  final double? wordSpacing,
  final double? height,
  final TextLeadingDistribution? leadingDistribution,
  final List<Shadow>? shadows,
  final List<FontFeature>? fontFeatures,
  final List<FontVariation>? fontVariations,
  final TextDecoration? decoration,
  final Color? decorationColor,
  final TextDecorationStyle? decorationStyle,
  final double? decorationThickness,
  final Paint? background,
  final Paint? foreground,
}) extends FlameTextStyle {
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
      wordSpacing: other.wordSpacing ?? wordSpacing,
      height: other.height ?? height,
      leadingDistribution: other.leadingDistribution ?? leadingDistribution,
      shadows: other.shadows ?? shadows,
      fontFeatures: other.fontFeatures ?? fontFeatures,
      fontVariations: other.fontVariations ?? fontVariations,
      decoration: other.decoration ?? decoration,
      decorationColor: other.decorationColor ?? decorationColor,
      decorationStyle: other.decorationStyle ?? decorationStyle,
      decorationThickness: other.decorationThickness ?? decorationThickness,
      background: other.background ?? background,
      foreground: other.foreground ?? foreground,
    );
  }

  TextPaint asTextRenderer() {
    return TextPaint(
      style: asTextStyle(),
    );
  }

  TextStyle asTextStyle() {
    return TextStyle(
      color: color,
      fontFamily: fontFamily,
      fontSize: fontSize! * (fontScale ?? 1.0),
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      leadingDistribution: leadingDistribution,
      shadows: shadows,
      fontFeatures: fontFeatures,
      fontVariations: fontVariations,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      background: background,
      foreground: foreground,
    );
  }
}
