import 'dart:ui';

import 'package:flutter/animation.dart';

import '../components/mixins/has_paint.dart';
import 'effects.dart';

class OpacityEffect extends ComponentEffect<HasPaint> {
  final double opacity;
  final double duration;
  final String? paintId;

  late Color _original;
  late Color _final;

  late double _difference;

  OpacityEffect({
    required this.opacity,
    required this.duration,
    this.paintId,
    bool isInfinite = false,
    bool isAlternating = false,
    Curve? curve,
    bool? removeOnFinish,
  }) : super(
          isInfinite,
          isAlternating,
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

    _original = affectedComponent!.getPaint(paintId).color;
    _final = _original.withOpacity(opacity);

    _difference = _original.opacity - opacity;
  }

  @override
  void setComponentToEndState() {
    affectedComponent!.setColor(
      _final,
      paintId: paintId,
    );
  }

  @override
  void setComponentToOriginalState() {
    affectedComponent?.setColor(
      _original,
      paintId: paintId,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    affectedComponent?.setOpacity(
      _original.opacity - _difference * curveProgress,
      paintId: paintId,
    );
  }
}
