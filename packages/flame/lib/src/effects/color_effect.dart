import 'dart:ui';

import 'package:flutter/animation.dart';

import '../components/mixins/has_paint.dart';
import 'effects.dart';

class ColorEffect extends ComponentEffect<HasPaint> {
  final Color color;
  final double duration;
  final String? paintId;

  late Paint _original;

  late ColorTween _tween;

  ColorEffect({
    required this.color,
    required this.duration,
    this.paintId,
    bool isInfinite = false,
    bool isAlternating = false,
    Curve? curve,
    bool? removeOnFinish,
  }) : super(
          isInfinite,
          isAlternating,
          removeOnFinish: removeOnFinish,
          curve: curve,
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    peakTime = duration;

    _original = affectedComponent!.getPaint(paintId);

    _tween = ColorTween(
      begin: _original.color,
      end: color,
    );
  }

  @override
  void setComponentToEndState() {
    affectedComponent?.tint(color);
  }

  @override
  void setComponentToOriginalState() {
    affectedComponent?.paint = _original;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final color = _tween.lerp(curveProgress);
    if (color != null) {
      affectedComponent?.tint(color);
    }
  }
}
