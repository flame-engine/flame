import 'package:flutter/animation.dart';
import 'package:meta/meta.dart';

import '../../components.dart';
import '../extensions/vector2.dart';
import 'effects.dart';

class ScaleEffect extends SimplePositionComponentEffect {
  Vector2 size;
  Vector2 _startSize;
  Vector2 _delta;

  /// Duration or speed needs to be defined
  ScaleEffect({
    @required this.size,
    double duration, // How long it should take for completion
    double speed, // The speed of the scaling in pixels per second
    Curve curve,
    bool isInfinite = false,
    bool isAlternating = false,
    bool isRelative = false,
    void Function() onComplete,
  })  : assert(
          duration != null || speed != null,
          'Either speed or duration necessary',
        ),
        super(
          isInfinite,
          isAlternating,
          duration: duration,
          speed: speed,
          curve: curve,
          isRelative: isRelative,
          modifiesSize: true,
          onComplete: onComplete,
        );

  @override
  void initialize(PositionComponent component) {
    super.initialize(component);
    _startSize = component.size;
    _delta = isRelative ? size : size - _startSize;
    if (!isAlternating) {
      endSize = _startSize + _delta;
    }
    speed ??= _delta.length / duration;
    duration ??= _delta.length / speed;
    peakTime = isAlternating ? duration / 2 : duration;
  }

  @override
  void update(double dt) {
    super.update(dt);
    component.size = _startSize + _delta * curveProgress;
  }
}
