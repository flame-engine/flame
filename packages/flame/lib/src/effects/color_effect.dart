import 'dart:ui';

import 'package:flutter/animation.dart';

import '../components/mixins/has_paint.dart';
import 'effects.dart';

class ColorEffect extends ComponentEffect<HasPaint> {
  final Color color;
  final double duration;
  final String? paintId;

  late Paint _original;
  late Paint _end;

  late ColorTween _tween;

  ColorEffect({
    required this.color,
    required this.duration,
    this.paintId,
    bool isInfinite = false,
    bool isAlternating = false,
    double? preOffset,
    double? postOffset,
    Curve? curve,
    bool? removeOnFinish,
  }) : super(
          isInfinite,
          isAlternating,
          preOffset: preOffset,
          postOffset: postOffset,
          removeOnFinish: removeOnFinish,
          curve: curve,
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    setPeakTimeFromDuration(duration);

    _original = affectedParent.getPaint(paintId);
    _end = Paint()..color = (isAlternating ? _original.color : color);

    _tween = ColorTween(
      begin: _original.color,
      end: color,
    );
  }

  @override
  void setComponentToEndState() {
    affectedParent.tint(_end.color);
  }

  @override
  void setComponentToOriginalState() {
    affectedParent.paint = _original;
  }

  @override
  void setEndToOriginalState() {
    _end.color = _original.color;
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
