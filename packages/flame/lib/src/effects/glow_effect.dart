import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';

class GlowEffect extends ComponentEffect<HasPaint> {
  GlowEffect(this.style, this.blurValue, super.controller, {this.paintId});

  final BlurStyle style;
  final double blurValue;
  final String? paintId;

  @override
  void apply(double progress) {
    final _value = blurValue * progress;

    target.paint.maskFilter = MaskFilter.blur(style, _value);
  }

  @override
  void reset() {
    super.reset();
    target.paint.maskFilter = null;
  }
}
