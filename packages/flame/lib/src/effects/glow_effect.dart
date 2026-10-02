import 'dart:ui';

import 'package:flame/effects.dart';

/// Change the MaskFilter on Paint of a component over time.
///
/// This effect applies incremental changes to the MaskFilter on Paint of a
/// component and requires that any other effect or update logic applied to the
/// same component also used incremental updates.
class GlowEffect(
  final double strength,
  super.controller, {
  final BlurStyle style = BlurStyle.outer,
  super.key,
}) extends Effect with EffectTarget<PaintProvider> {
  @override
  void apply(double progress) {
    target.paint.maskFilter = MaskFilter.blur(style, strength * progress);
  }

  @override
  void reset() {
    super.reset();
    target.paint.maskFilter = null;
  }
}
