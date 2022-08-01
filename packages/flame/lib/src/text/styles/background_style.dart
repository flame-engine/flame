import 'package:flame/src/text/styles/style.dart';
import 'package:flutter/rendering.dart';

class BackgroundStyle extends Style {
  BackgroundStyle({
    Color? color,
    Paint? paint,
    Color? borderColor,
    double? borderRadius,
    double? borderWidth,
  })  : assert(
          paint == null || color == null,
          'Parameters `paint` and `color` are exclusive',
        ),
        borderWidths = EdgeInsets.all(borderWidth ?? 0),
        borderRadius = borderRadius ?? 0 {
    if (paint != null) {
      backgroundPaint = paint;
    } else if (color != null) {
      backgroundPaint = Paint()..color = color;
    } else {
      backgroundPaint = null;
    }
    if (borderColor != null) {
      borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth ?? 0;
    } else {
      borderPaint = null;
    }
  }

  late final Paint? backgroundPaint;
  late final Paint? borderPaint;
  final double borderRadius;
  final EdgeInsets borderWidths;

  @override
  BackgroundStyle clone() => copyWith();

  BackgroundStyle copyWith({
    Color? color,
    Paint? paint,
    Color? borderColor,
    double? borderRadius,
    double? borderWidth,
  }) {
    return BackgroundStyle(
      color: color ?? (paint == null ? backgroundPaint?.color : null),
      paint: paint ?? backgroundPaint,
      borderColor: borderColor ?? borderPaint?.color,
      borderRadius: borderRadius ?? this.borderRadius,
      borderWidth: borderWidth ?? borderWidths.left,
    );
  }
}
