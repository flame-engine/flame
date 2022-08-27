import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/src/text/common/line_metrics.dart';
import 'package:flame/src/text/common/text_line.dart';
import 'package:flame/src/text/elements/text_element.dart';

class SpriteFontTextElement extends TextElement implements TextLine {
  SpriteFontTextElement({
    required this.source,
    required this.transforms,
    required this.rects,
    required this.paint,
    required LineMetrics metrics,
  }) : _box = metrics;

  final Image source;
  final Float32List transforms;
  final Float32List rects;
  final Paint paint;
  final LineMetrics _box;

  @override
  TextLine get lastLine => this;

  @override
  LineMetrics get metrics => _box;

  @override
  void translate(double dx, double dy) {
    _box.translate(dx, dy);
    for (var i = 0; i < transforms.length; i += 4) {
      transforms[i + 2] += dx;
      transforms[i + 3] += dy;
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRawAtlas(source, transforms, rects, null, null, null, paint);
  }
}
