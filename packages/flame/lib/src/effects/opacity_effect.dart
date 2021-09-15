import 'dart:ui';

import 'package:flutter/animation.dart';

import '../components/mixins/has_paint.dart';
import 'effects.dart';

class OpacityEffect extends ComponentEffect<HasPaint> {
  final double opacity;
  final double duration;
  final String? paintId;

  late Color _original;
  late Color _peak;

  late double _difference;

  OpacityEffect({
    required this.opacity,
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
          curve: curve,
          removeOnFinish: removeOnFinish,
        );

  OpacityEffect.fadeOut({
    this.duration = 1,
    this.paintId,
    Curve? curve,
    bool isInfinite = false,
    bool isAlternating = false,
  })  : opacity = 0,
        super(
          isInfinite,
          isAlternating,
          curve: curve,
        );

  OpacityEffect.fadeIn({
    this.duration = 1,
    this.paintId,
    Curve? curve,
    bool isInfinite = false,
    bool isAlternating = false,
  })  : opacity = 1,
        super(
          isInfinite,
          isAlternating,
          curve: curve,
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    peakTime = duration;

    _original = affectedParent.getPaint(paintId).color;
    _peak = _original.withOpacity(opacity);

    _difference = _original.opacity - opacity;
    setPeakTimeFromDuration(duration);
  }

  @override
  void setComponentToPeakState() {
    affectedParent.setColor(
      _peak,
      paintId: paintId,
    );
  }

  @override
  void setComponentToOriginalState() {
    affectedParent.setColor(
      _original,
      paintId: paintId,
    );
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
    affectedParent.setOpacity(
      _original.opacity - _difference * curveProgress,
      paintId: paintId,
    );
  }
}
