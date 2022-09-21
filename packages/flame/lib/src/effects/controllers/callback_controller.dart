import 'dart:ui';
import 'package:flame/effects.dart';

/// callback will be invoked after the effect's duration or reverseDuration
/// has been reached.
class CallbackController extends DurationEffectController {
  CallbackController({required this.callback, required double progress})
      : _progress = progress,
        super(0.0);

  final VoidCallback callback;
  final double _progress;

  @override
  double get progress => _progress;

  @override
  bool get completed => true;

  @override
  double advance(double dt) {
    callback();
    return 1;
  }

  @override
  double recede(double dt) {
    callback();
    return 1;
  }
}
