import 'dart:ui';

import 'package:flame/src/effects/controllers/effect_controller.dart';
import 'package:flame/src/effects/effect.dart';
import 'package:flame/src/effects/effect_target.dart';
import 'package:flame/src/effects/provider_interfaces.dart';
import 'package:flame/src/rendering/hue_decorator.dart';

/// An effect that changes the hue of a component over time.
///
/// This effect applies incremental changes to the [ColorFilter] of the paint of
/// a component and requires that the component implement [PaintProvider].
class HueEffect extends Effect with EffectTarget<PaintProvider> {
  HueEffect(
    this.angle,
    EffectController controller, {
    super.key,
    super.onComplete,
  }) : super(controller);

  /// Target hue rotation angle in radians.
  final double angle;

  @override
  void apply(double progress) {
    target.paint.colorFilter = ColorFilter.matrix(
      HueDecorator.hueMatrix(angle * progress),
    );
  }

  @override
  void reset() {
    super.reset();
    target.paint.colorFilter = null;
  }
}
