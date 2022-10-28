import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';

class GlowEffect extends ComponentEffect<HasPaint> {
  GlowEffect(this.filter, super.controller, {this.paintId});

  final MaskFilter filter;
  final String? paintId;


  @override
  void apply(double progress) {
    target.paint.maskFilter = filter;
  }
}
