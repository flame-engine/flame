import 'dart:ui';

import 'package:flame/src/text/elements/element.dart';
import 'package:flame/src/text/elements/rect_background_element.dart';
import 'package:flame/src/text/elements/rrect_background_element.dart';

class BackgroundStyle {
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
        _borderRadius = borderRadius ?? 0 {
    if (paint != null) {
      _backgroundPaint = paint;
    } else if (color != null) {
      _backgroundPaint = Paint()..color = color;
    } else {
      _backgroundPaint = null;
    }
    if (borderColor != null) {
      _borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth ?? 0;
    } else {
      _borderPaint = null;
    }
  }

  late final Paint? _backgroundPaint;
  late final Paint? _borderPaint;
  final double _borderRadius;

  Element? format(double width, double height) {
    final paints = <Paint>[
      if (_backgroundPaint != null) _backgroundPaint!,
      if (_borderPaint != null) _borderPaint!,
    ];
    if (paints.isEmpty) {
      return null;
    }
    if (_borderRadius == 0) {
      return RectBackgroundElement(width, height, paints);
    } else {
      return RRectBackgroundElement(width, height, _borderRadius, paints);
    }
  }
}
