import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// The length of each dash of the preview outlines, and of the gap after
/// it.
const dashLength = 4.0;

/// Draws the closed outline through [points] on [canvas] with [paint], as a
/// dashed line.
void drawDashedPolygon(Canvas canvas, List<Offset> points, Paint paint) {
  for (var i = 0; i < points.length; i++) {
    _drawDashedLine(canvas, points[i], points[(i + 1) % points.length], paint);
  }
}

/// Draws a circle of [radius] around [center] on [canvas] with [paint], as
/// a dashed line.
void drawDashedCircle(
  Canvas canvas,
  Offset center,
  double radius,
  Paint paint,
) {
  if (radius <= 0) {
    return;
  }
  final circumference = 2 * math.pi * radius;
  // A whole number of dashes and gaps, so the last gap closes the circle.
  final dashes = math.max(1, (circumference / (dashLength * 2)).round());
  final step = 2 * math.pi / dashes;
  final rect = Rect.fromCircle(center: center, radius: radius);
  for (var i = 0; i < dashes; i++) {
    canvas.drawArc(rect, i * step, step / 2, false, paint);
  }
}

void _drawDashedLine(Canvas canvas, Offset from, Offset to, Paint paint) {
  final length = (to - from).distance;
  if (length == 0) {
    return;
  }
  final direction = (to - from) / length;
  for (var start = 0.0; start < length; start += dashLength * 2) {
    final end = math.min(start + dashLength, length);
    canvas.drawLine(from + direction * start, from + direction * end, paint);
  }
}
