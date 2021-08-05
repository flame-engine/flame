import 'dart:ui';

import 'package:flutter/animation.dart';

import '../../components.dart';
import '../extensions/vector2.dart';
import 'effects.dart';

class ScaleEffect extends SimplePositionComponentEffect {
  Vector2 scale;
  late Vector2 _startScale;
  late Vector2 _delta;

  /// Duration or speed needs to be defined
  ScaleEffect({
    required this.scale,
    double? duration, // How long it should take for completion
    double? speed, // The speed of the scaling in pixels per second
    Curve? curve,
    bool isInfinite = false,
    bool isAlternating = false,
    bool isRelative = false,
    VoidCallback? onComplete,
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
          modifiesScale: true,
          onComplete: onComplete,
        );

  @override
  void initialize(PositionComponent component) {
    super.initialize(component);
    _startScale = component.scale.clone();
    _delta = isRelative ? scale : scale - _startScale;
    if (!isAlternating) {
      endScale = _startScale + _delta;
    }
    speed ??= _delta.length / duration!;
    duration ??= _delta.length / speed!;
    peakTime = isAlternating ? duration! / 2 : duration!;
  }

  @override
  void update(double dt) {
    super.update(dt);
    component?.scale.setFrom(_startScale + _delta * curveProgress);
  }
}
