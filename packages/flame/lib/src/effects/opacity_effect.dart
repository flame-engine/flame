import 'package:flame/effects.dart';
import 'package:flame/src/effects/provider_interfaces.dart';

/// Change the opacity of a component over time.
///
/// This effect applies incremental changes to the component's opacity, and
/// requires that any other effect or update logic applied to the same component
/// also used incremental updates.
class OpacityEffect extends Effect with EffectTarget<OpacityProvider> {
  int _alphaOffset;
  double _roundingError = 0.0;

  /// This constructor will set the opacity in relation to it's current opacity
  /// over time.
  OpacityEffect.by(
    double offset,
    super.controller, {
    OpacityProvider? target,
    super.onComplete,
  }) : _alphaOffset = (255 * offset).round() {
    this.target = target;
  }

  /// This constructor will set the opacity to the specified opacity over time.
  factory OpacityEffect.to(
    double targetOpacity,
    EffectController controller, {
    OpacityProvider? target,
    void Function()? onComplete,
  }) {
    return _OpacityToEffect(
      targetOpacity,
      controller,
      target: target,
      onComplete: onComplete,
    );
  }

  factory OpacityEffect.fadeIn(
    EffectController controller, {
    OpacityProvider? target,
    void Function()? onComplete,
  }) {
    return _OpacityToEffect(
      1.0,
      controller,
      target: target,
      onComplete: onComplete,
    );
  }

  factory OpacityEffect.fadeOut(
    EffectController controller, {
    OpacityProvider? target,
    void Function()? onComplete,
  }) {
    return _OpacityToEffect(
      0.0,
      controller,
      target: target,
      onComplete: onComplete,
    );
  }

  @override
  void apply(double progress) {
    final deltaProgress = progress - previousProgress;
    final deltaAlpha =
        (_alphaOffset * deltaProgress) + _roundingError * deltaProgress.sign;
    final currentAlpha = (target.opacity * 255).round();
    var nextAlpha = (currentAlpha + deltaAlpha).round();
    _roundingError = (currentAlpha + deltaAlpha) - nextAlpha;
    nextAlpha = nextAlpha.clamp(0, 255);
    target.opacity = nextAlpha / 255;
  }

  @override
  void reset() {
    super.reset();
    // We can't accumulate rounding errors between resets because we don't know
    // if the opacity has been affected by anything else in between.
    _roundingError = 0.0;
  }
}

/// Implementation class for [OpacityEffect.to]
class _OpacityToEffect extends OpacityEffect {
  final double _targetOpacity;

  _OpacityToEffect(
    this._targetOpacity,
    EffectController controller, {
    OpacityProvider? target,
    void Function()? onComplete,
  }) : super.by(
          0.0,
          controller,
          target: target,
          onComplete: onComplete,
        );

  @override
  void onStart() {
    _alphaOffset = ((_targetOpacity - target.opacity) * 255).round();
  }
}
