import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/text.dart';

class SpriteFontTextElement({
  required final Image source,
  required final Float32List transforms,
  required final Float32List rects,
  required final Paint paint,
  required LineMetrics metrics,
}) extends InlineTextElement {
  final LineMetrics _box = metrics;

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
  void draw(Canvas canvas) {
    canvas.drawRawAtlas(source, transforms, rects, null, null, null, paint);
  }
}
