import 'package:flame/components.dart';
import 'package:flame/src/effects/controllers/effect_controller.dart';
import 'package:flame/src/effects/effect.dart';
import 'package:flame/src/effects/effect_target.dart';
import 'package:flame/src/effects/hue_by_effect.dart';
import 'package:flame/src/effects/hue_to_effect.dart';
import 'package:flame/src/effects/provider_interfaces.dart';

/// An effect that changes the hue of a component over time.
///
/// This effect applies incremental changes to the hue property of the target,
/// and requires that any other effect or update logic applied to the same
/// target also used incremental updates.
abstract class HueEffect extends Effect with EffectTarget<HueProvider> {
  HueEffect(
    super.controller, {
    super.onComplete,
    super.key,
  });

  factory HueEffect.by(
    double angle,
    EffectController controller, {
    HueProvider? target,
    void Function()? onComplete,
    ComponentKey? key,
  }) {
    return HueByEffect(
      angle,
      controller,
      target: target,
      onComplete: onComplete,
      key: key,
    );
  }

  factory HueEffect.to(
    double angle,
    EffectController controller, {
    HueProvider? target,
    void Function()? onComplete,
    ComponentKey? key,
  }) {
    return HueToEffect(
      angle,
      controller,
      target: target,
      onComplete: onComplete,
      key: key,
    );
  }
}
