import 'package:flame/components.dart';
import 'package:flame/src/effects/component_effect.dart';
import 'package:flame/src/effects/controllers/effect_controller.dart';

/// Change the opacity of a component over time.
///
/// This effect applies incremental changes to the component's opacity, and
/// requires that any other effect or update logic applied to the same component
/// also used incremental updates.
class OpacityEffect extends ComponentEffect<HasPaint> {
  int _alphaOffset;
  double _roundingError = 0.0;
  final String? paintId;

  /// This constructor will set the opacity in relation to it's current opacity
  /// over time.
  OpacityEffect.by(
    double offset,
    super.controller, {
    this.paintId,
    super.onComplete,
  }) : _alphaOffset = (255 * offset).round();

  /// This constructor will set the opacity to the specified opacity over time.
  factory OpacityEffect.to(
    double targetOpacity,
    EffectController controller, {
    String? paintId,
    void Function()? onComplete,
  }) {
    return _OpacityToEffect(
      targetOpacity,
      controller,
      paintId: paintId,
      onComplete: onComplete,
    );
  }

  factory OpacityEffect.fadeIn(
    EffectController controller, {
    String? paintId,
    void Function()? onComplete,
  }) {
    return _OpacityToEffect(
      1.0,
      controller,
      paintId: paintId,
      onComplete: onComplete,
    );
  }

  factory OpacityEffect.fadeOut(
    EffectController controller, {
    String? paintId,
    void Function()? onComplete,
  }) {
    return _OpacityToEffect(
      0.0,
      controller,
      paintId: paintId,
      onComplete: onComplete,
    );
  }

  @override
  void apply(double progress) {
    final deltaProgress = progress - previousProgress;
    final currentAlpha = target.getAlpha(paintId: paintId);
    final deltaAlpha =
        (_alphaOffset * deltaProgress) + _roundingError * deltaProgress.sign;
    var nextAlpha = (currentAlpha + deltaAlpha).round();
    _roundingError = (currentAlpha + deltaAlpha) - nextAlpha;
    nextAlpha = nextAlpha.clamp(0, 255);
    target.setAlpha(nextAlpha, paintId: paintId);
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
    String? paintId,
    void Function()? onComplete,
  }) : super.by(
          0.0,
          controller,
          paintId: paintId,
          onComplete: onComplete,
        );

  @override
  void onStart() {
    _alphaOffset =
        (_targetOpacity * 255 - target.getAlpha(paintId: paintId)).round();
  }
}
