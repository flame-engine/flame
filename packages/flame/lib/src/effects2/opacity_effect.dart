import '../../components.dart';
import 'component_effect.dart';
import 'effect_controller.dart';

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
    EffectController controller, {
    this.paintId,
  })  : _alphaOffset = (255 * offset).round(),
        super(controller);

  /// This constructor will set the opacity to the specified opacity over time.
  factory OpacityEffect.to(
    double targetOpacity,
    EffectController controller, {
    String? paintId,
  }) {
    return _OpacityToEffect(targetOpacity, controller, paintId: paintId);
  }

  factory OpacityEffect.fadeIn(
    EffectController controller, {
    String? paintId,
  }) {
    return _OpacityToEffect(1.0, controller, paintId: paintId);
  }

  factory OpacityEffect.fadeOut(
    EffectController controller, {
    String? paintId,
  }) {
    return _OpacityToEffect(0.0, controller, paintId: paintId);
  }

  @override
  void apply(double progress) {
    final dProgress = progress - previousProgress;
    final currentAlpha = target.getAlpha(paintId: paintId);
    final dOffset =
        (_alphaOffset * dProgress) + _roundingError * dProgress.sign;
    _roundingError = (dOffset.remainder(1.0) - 0.5).abs();
    final nextAlpha = (currentAlpha + dOffset).round().clamp(0, 255);
    target.setAlpha(nextAlpha, paintId: paintId);
    super.apply(progress);
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
  }) : super.by(0.0, controller, paintId: paintId);

  @override
  void onStart() {
    _alphaOffset =
        (_targetOpacity * 255 - target.getAlpha(paintId: paintId)).round();
  }
}
