import 'duration_effect_controller.dart';

/// A controller that keeps constant progress level over [duration] seconds.
class PauseEffectController extends DurationEffectController {
  PauseEffectController({required double duration, required double level})
      : _progress = level,
        super(duration);

  final double _progress;

  @override
  double get progress => _progress;
}
