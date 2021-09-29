import 'dart:ui';

import 'package:flame/src/effects/flame_animation_controller.dart';
import 'package:flutter/animation.dart';

import '../../components.dart';
import '../extensions/vector2.dart';
import 'effect_component.dart';
import 'effects.dart';

class ScaleEffect extends PositionComponentEffect {
  Vector2 scale;
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
    double? initialDelay,
    double? peakDelay,
    bool? removeOnFinish,
    VoidCallback? onComplete,
  }) : super(
          isInfinite,
          isAlternating,
          duration: duration,
          speed: speed,
          curve: curve,
          isRelative: isRelative,
          modifiesScale: true,
          initialDelay: initialDelay,
          peakDelay: peakDelay,
          removeOnFinish: removeOnFinish,
          onComplete: onComplete,
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final startScale = originalScale!;
    _delta = isRelative ? scale : scale - startScale;
    peakScale = startScale + _delta;
    speed ??= _delta.length / duration!;
    duration ??= _delta.length / speed!;
    setPeakTimeFromDuration(duration!);
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
    affectedParent.scale.setFrom(originalScale! + _delta * curveProgress);
  }
}

class ScaleEffect2 extends EffectComponent {
  ScaleEffect2({
    required Vector2 scale,
    required FlameAnimationController controller,
    bool absolute = false,
    bool? removeOnFinish,
  })  : effectValue = scale.clone(),
        isAbsolute = absolute,
        super(controller: controller, removeOnFinish: removeOnFinish);

  final Vector2 effectValue;
  final bool isAbsolute;

  @override
  void onStart() {

  }
  @override
  void apply(double progress) {
    // TODO: implement apply
  }
}
