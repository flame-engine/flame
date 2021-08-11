import 'dart:ui';

import 'package:flutter/animation.dart';

import '../../components.dart';
import '../extensions/vector2.dart';
import 'effects.dart';

class SizeEffect extends SimplePositionComponentEffect {
  Vector2 size;
  late Vector2 _startSize;
  late Vector2 _delta;

  /// Duration or speed needs to be defined
  SizeEffect({
    required this.size,
    double? duration, // How long it should take for completion
    double? speed, // The speed of the scaling in pixels per second
    Curve? curve,
    bool isInfinite = false,
    bool isAlternating = false,
    bool isRelative = false,
    double? preOffset,
    double? postOffset,
    bool? removeOnFinish,
    VoidCallback? onComplete,
  }) : super(
          isInfinite,
          isAlternating,
          duration: duration,
          speed: speed,
          curve: curve,
          isRelative: isRelative,
          modifiesSize: true,
          preOffset: preOffset,
          postOffset: postOffset,
          removeOnFinish: removeOnFinish,
          onComplete: onComplete,
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _startSize = affectedParent!.size.clone();
    _delta = isRelative ? size : size - _startSize;
    if (!isAlternating) {
      endSize = _startSize + _delta;
    }
    speed ??= _delta.length / duration!;
    duration ??= _delta.length / speed!;
    setPeakTimeFromDuration(duration!);
  }

  @override
  void update(double dt) {
    super.update(dt);
    affectedParent!.size.setFrom(_startSize + _delta * curveProgress);
  }
}
