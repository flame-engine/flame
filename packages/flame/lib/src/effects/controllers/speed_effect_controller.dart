import '../effect.dart';
import '../measurable_effect.dart';
import 'duration_effect_controller.dart';
import 'effect_controller.dart';

class SpeedEffectController extends EffectController {
  SpeedEffectController(this.child, {required this.speed})
      : assert(speed > 0, 'speed must be positive: $speed'),
        super.empty();

  final DurationEffectController child;
  final double speed;
  late MeasurableEffect _parentEffect;
  bool _started = false;

  @override
  bool get isRandom => child.isRandom;

  @override
  bool get completed => child.completed;

  @override
  double? get duration => child.duration;

  @override
  double get progress => child.progress;

  @override
  double advance(double dt) {
    if (!_started) {
      _started = true;
      final measure = _parentEffect.measure();
      child.duration = measure / speed;
    }
    return child.advance(dt);
  }

  @override
  double recede(double dt) {
    final t = child.recede(dt);
    if (t > 0) {
      _started = false;
    }
    return t;
  }

  @override
  void setToEnd() {
    _started = true;
    child.setToEnd();
  }

  @override
  void setToStart() {
    _started = false;
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
