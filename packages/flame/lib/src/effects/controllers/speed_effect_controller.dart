import 'package:flame/effects.dart';
import 'package:flame/src/effects/measurable_effect.dart';

/// This controller can force execution of an effect at a predefined speed.
///
/// For most of the effect controllers, their duration is set by the user in
/// advance. This controller is different: it knows the target speed at which
/// the parent effect wants to proceed, communicates with the effect to
/// determine its total distance, and uses that to calculate the desired
/// duration for the [child] effect controller.
///
/// Some restrictions apply:
///   - the [speed] cannot be zero (or negative),
///   - the [child] controller must be a [DurationEffectController],
///   - the parent effect must be a [MeasurableEffect].
class SpeedEffectController extends EffectController
    with HasSingleChildEffectController<DurationEffectController> {
  SpeedEffectController(DurationEffectController child, {required this.speed})
      : assert(speed > 0, 'Speed must be positive: $speed'),
        _child = child,
        super.empty();

  final DurationEffectController _child;
  final double speed;
  MeasurableEffect? _parentEffect;

  /// Note that this controller's [started] property is true even if the
  /// controller is not initialized yet. This is because we want the [Effect]
  /// to run its `onStart()` callback before we initialize the controller
  /// (which will happen at the first call to `advance()`).
  bool _initialized = false;

  @override
  DurationEffectController get child => _child;

  @override
  bool get isRandom => true;

  @override
  bool get completed => child.completed;

  /// The duration of the effect.
  ///
  /// If this is called before the effect has started, it might not have the
  /// correct duration when it is later used, for example if you're using a
  /// [DelayedEffectController] and then the component moves before the delay
  /// is over.
  @override
  double get duration {
    return _initialized
        ? child.duration
        : (_parentEffect?.measure() ?? double.nan) / speed;
  }

  @override
  double get progress => child.progress;

  @override
  double advance(double dt) {
    if (!_initialized) {
      child.duration = duration;
      _initialized = true;
    }
    return child.advance(dt);
  }

  @override
  double recede(double dt) {
    final t = child.recede(dt);
    if (t > 0) {
      _initialized = false;
    }
    return t;
  }

  @override
  void setToEnd() {
    _initialized = false;
    super.setToEnd();
  }

  @override
  void setToStart() {
    _initialized = false;
    super.setToStart();
  }

  @override
  void onMount(Effect parent) {
    assert(
      parent is MeasurableEffect,
      'SpeedEffectController can only be applied to a MeasurableEffect',
    );
    _parentEffect = parent as MeasurableEffect;
    super.onMount(parent);
  }
}
