import 'dart:ui';
import 'package:flame/effects.dart';

/// The [callback] will be invoked once the effect's [progress] is reached.
/// 1.0 to match `duration` or 0.0 to match when the `reverseDuration`
/// has been reached.
class CallbackController extends DurationEffectController {
  CallbackController(this.callback, {required double progress})
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
    return dt;
  }

  @override
  double recede(double dt) {
    callback();
    return dt;
  }
}
