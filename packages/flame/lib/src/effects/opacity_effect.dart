import 'package:flame/components.dart';
import 'package:flame/src/effects/component_effect.dart';
import 'package:flame/src/effects/controllers/effect_controller.dart';

/// Change the opacity of a component over time.
///
/// This effect applies incremental changes to the component's opacity, and
/// requires that any other effect or update logic applied to the same component
/// also used incremental updates.
class OpacityEffect extends ComponentEffect<HasPaint> {
  /// This constructor will set the opacity in relation to it's current opacity
  /// over time.
  OpacityEffect.by(
    double offset,
    super.controller, {
    this.paintId,
    super.onComplete,
  }) : _opacityOffset = offset;

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

  double _opacityOffset;
  double _roundingError = 0.0;
  final String? paintId;

  @override
  void apply(double progress) {
    final deltaProgress = progress - previousProgress;
    final currentOpacity = target.getOpacity(paintId: paintId) + _roundingError;
    final deltaOpacity = _opacityOffset * deltaProgress;
    final newOpacity = (currentOpacity + deltaOpacity).clamp(0, 1).toDouble();
    target.setOpacity(newOpacity, paintId: paintId);
    _roundingError = newOpacity - target.getOpacity(paintId: paintId);
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
    _opacityOffset = _targetOpacity - target.getOpacity(paintId: paintId);
  }
}
