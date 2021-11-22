import '../../components.dart';
import 'component_effect.dart';
import 'effect_controller.dart';

/// Change the opacity of a component over time.
///
/// The following constructors are provided:
///
///   - [OpacityEffect.by] will set the opacity in relation to it's current opacity;
///   - [OpacityEffect.to] will set the opacity to the specified opacity
///
/// This effect applies incremental changes to the component's opacity, and
/// requires that any other effect or update logic applied to the same component
/// also used incremental updates.
class OpacityEffect extends ComponentEffect<HasPaint> {
  int _alphaOffset;
  double _roundingError = 0.0;
  final String? paintId;

  OpacityEffect.by(
    double offset,
    EffectController controller, {
    this.paintId,
  })  : _alphaOffset = (255 * offset).round(),
        super(controller);

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
    final dOffset = (_alphaOffset * dProgress) + _roundingError;
    _roundingError = dOffset.remainder(1.0) - 0.5 * dProgress.sign;
    final unroundedAlpha = currentAlpha + dOffset;
    final newAlpha = unroundedAlpha.round().clamp(0, 255);
    target.setAlpha(newAlpha, paintId: paintId);
    super.apply(progress);
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
