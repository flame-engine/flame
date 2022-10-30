import 'package:flame/effects.dart';

/// Change the opacity of a component over time.
///
/// This effect applies incremental changes to the component's opacity, and
/// requires that any other effect or update logic applied to the same component
/// also used incremental updates.
class OpacityEffect extends Effect with EffectTarget<OpacityProvider> {
  /// This constructor will set the opacity in relation to it's current opacity
  /// over time.
  OpacityEffect.by(
    double offset,
    super.controller, {
    OpacityProvider? target,
    super.onComplete,
  }) : _opacityOffset = offset {
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

  double _opacityOffset;
  double _roundingError = 0.0;

  @override
  void apply(double progress) {
    final deltaProgress = progress - previousProgress;
    final currentOpacity = target.opacity + _roundingError;
    final deltaOpacity = _opacityOffset * deltaProgress;
    final newOpacity = (currentOpacity + deltaOpacity).clamp(0, 1).toDouble();
    target.opacity = newOpacity;
    _roundingError = newOpacity - target.opacity;
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
    _opacityOffset = _targetOpacity - target.opacity;
  }
}
