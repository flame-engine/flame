import 'package:flame/src/anchor.dart';
import 'package:flame/src/effects/anchor_by_effect.dart';
import 'package:flame/src/effects/anchor_to_effect.dart';
import 'package:flame/src/effects/controllers/effect_controller.dart';
import 'package:flame/src/effects/effect.dart';
import 'package:flame/src/effects/effect_target.dart';
import 'package:flame/src/effects/measurable_effect.dart';
import 'package:flame/src/effects/provider_interfaces.dart';
import 'package:vector_math/vector_math_64.dart';

/// Base class for effects that affect the `anchor` of their targets.
///
/// The main purpose of this class is for type reflection, for example to select
/// all effects on the target that are of "anchor" type.
///
/// Factory constructors [AnchorEffect.by] and [AnchorEffect.to] are also
/// provided for convenience.
abstract class AnchorEffect extends Effect
    with EffectTarget<AnchorProvider>
    implements MeasurableEffect {
  AnchorEffect(
    super.controller,
    AnchorProvider? target, {
    super.onComplete,
  }) {
    this.target = target;
  }

  factory AnchorEffect.by(
    Vector2 offset,
    EffectController controller, {
    AnchorProvider? target,
    void Function()? onComplete,
  }) =>
      AnchorByEffect(
        offset,
        controller,
        target: target,
        onComplete: onComplete,
      );

  factory AnchorEffect.to(
    Anchor destination,
    EffectController controller, {
    AnchorProvider? target,
    void Function()? onComplete,
  }) =>
      AnchorToEffect(
        destination,
        controller,
        target: target,
        onComplete: onComplete,
      );
}
