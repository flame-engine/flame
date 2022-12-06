import 'dart:ui';

import 'package:flame/effects.dart';
import 'package:flame/src/effects/provider_interfaces.dart';
import 'package:meta/meta.dart';

/// Change the MaskFilter on Paint of a component over time.
///
/// This effect applies incremental changes to the MaskFilter on Paint of a
/// component and requires that any other effect or update logic applied to the
/// same component also used incremental updates.
@experimental
class GlowEffect extends Effect with EffectTarget<PaintProvider> {
  GlowEffect(this.strength, super.controller, {this.style = BlurStyle.outer});

  final BlurStyle style;
  final double strength;

  @override
  void apply(double progress) {
    final _value = strength * progress;

    target.paint.maskFilter = MaskFilter.blur(style, _value);
  }

  @override
  void reset() {
    super.reset();
    target.paint.maskFilter = null;
  }
}
