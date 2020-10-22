import 'package:flutter/animation.dart';
import 'package:meta/meta.dart';

import '../extensions/vector2.dart';
import 'effects.dart';

class ScaleEffect extends SimplePositionComponentEffect {
  Vector2 size;
  Vector2 _startSize;
  Vector2 _delta;

  ScaleEffect({
    @required this.size,
    double duration, // How long it should take for completion
    double speed, // The speed of the scaling in pixels/s
    Curve curve,
    bool isInfinite = false,
    bool isAlternating = false,
    bool isRelative = false,
    void Function() onComplete,
  })  : assert(duration != null || speed != null),
        super(
          isInfinite,
          isAlternating,
          duration: duration,
          speed: speed,
          curve: curve,
          isRelative: isRelative,
          onComplete: onComplete,
        );

  @override
  void initialize(_comp) {
    super.initialize(_comp);
    if (!isAlternating) {
      endSize = size.clone();
    }
    _startSize = component.size;
    _delta = isRelative ? size : size - _startSize;
    speed ??= _delta.length / duration;
    duration ??= _delta.length / speed;
    travelTime = duration;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final double progress = curve?.transform(percentage) ?? 1.0;
    component.size = _startSize + _delta * progress;
  }
}
