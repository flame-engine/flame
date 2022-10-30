import 'package:flame/src/effects/controllers/duration_effect_controller.dart';
import 'package:flame/src/effects/controllers/effect_controller.dart';
import 'package:flame/src/effects/effect.dart';
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
class SpeedEffectController extends EffectController {
  SpeedEffectController(this.child, {required this.speed})
      : assert(speed > 0, 'Speed must be positive: $speed'),
        super.empty();

  final DurationEffectController child;
  final double speed;
  late MeasurableEffect _parentEffect;

  /// Note that this controller's [started] property is true even if the
  /// controller is not initialized yet. This is because we want the [Effect]
  /// to run its `onStart()` callback before we initialize the controller
  /// (which will happen at the first call to `advance()`).
  bool _initialized = false;

  @override
  bool get isRandom => true;

  @override
  bool get completed => child.completed;

  @override
  double? get duration => _initialized ? child.duration : double.nan;

  @override
  double get progress => child.progress;

  @override
  double advance(double dt) {
    if (!_initialized) {
      _initialized = true;
      final measure = _parentEffect.measure();
      assert(
        measure >= 0,
        'negative measure returned by ${_parentEffect.runtimeType}: $measure',
      );
      child.duration = measure / speed;
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
    child.setToEnd();
  }

  @override
  void setToStart() {
    _initialized = false;
    child.setToStart();
  }

  @override
  void onMount(Effect parent) {
    assert(
      parent is MeasurableEffect,
      'SpeedEffectController can only be applied to a MeasurableEffect',
    );
    _parentEffect = parent as MeasurableEffect;
    child.onMount(parent);
  }
}
