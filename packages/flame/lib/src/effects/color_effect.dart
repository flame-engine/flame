import 'dart:ui';

import 'package:flutter/animation.dart';

import '../components/mixins/has_paint.dart';
import 'effects.dart';

class ColorEffect extends ComponentEffect<HasPaint> {
  final Color color;
  final double duration;
  final String? paintId;

  late Paint _original;
  late Paint _peak;

  late ColorTween _tween;

  ColorEffect({
    required this.color,
    required this.duration,
    this.paintId,
    bool isInfinite = false,
    bool isAlternating = false,
    double? initialDelay,
    double? peakDelay,
    Curve? curve,
    bool? removeOnFinish,
  }) : super(
          isInfinite,
          isAlternating,
          initialDelay: initialDelay,
          peakDelay: peakDelay,
          removeOnFinish: removeOnFinish,
          curve: curve,
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    setPeakTimeFromDuration(duration);

    _original = affectedParent.getPaint(paintId);
    _peak = Paint()..color = color;

    _tween = ColorTween(
      begin: _original.color,
      end: color,
    );
  }

  @override
  void setComponentToOriginalState() {
    affectedParent.paint = _original;
  }

  @override
  void setComponentToPeakState() {
    affectedParent.tint(_peak.color);
  }

  @override
  void update(double dt) {
    if (isPaused) {
      return;
    }
    super.update(dt);
    if (hasCompleted()) {
      return;
    }
    final color = _tween.lerp(curveProgress);
    if (color != null) {
      affectedParent.tint(color);
    }
  }
}
