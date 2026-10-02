import 'package:flame/text.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

@immutable
// ignore: prefer_const_constructors_in_immutables
class BackgroundStyle({
  Color? color,
  Paint? paint,
  Color? borderColor,
  double? borderRadius,
  double? borderWidth,
}) extends FlameTextStyle {
  this
    : assert(
        paint == null || color == null,
        'Parameters `paint` and `color` are exclusive',
      );

  final Paint? backgroundPaint =
      paint ?? (color != null ? (Paint()..color = color) : null);
  final Paint? borderPaint = borderColor != null
      ? (Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth ?? 0)
      : null;
  final double borderRadius = borderRadius ?? 0;
  final EdgeInsets borderWidths = EdgeInsets.all(borderWidth ?? 0);

  @override
  BackgroundStyle copyWith(BackgroundStyle other) {
    return BackgroundStyle(
      paint: other.backgroundPaint ?? backgroundPaint,
      borderColor: other.borderPaint?.color ?? borderPaint?.color,
      borderRadius: other.borderRadius,
      borderWidth: other.borderWidths.top,
    );
  }
}
