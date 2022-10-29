import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';

class GlowEffect extends ComponentEffect<HasPaint> {
  GlowEffect(this.strength, super.controller, {this.style = BlurStyle.outer});

  final BlurStyle style;
  final double strength;

  @override
  void apply(double progress) {
    final _value = strength * progress;

    target.paint.maskFilter = MaskFilter.blur(style, _value);
  }

  @override
  void reset() {
    super.reset();
    target.paint.maskFilter = null;
  }
}
