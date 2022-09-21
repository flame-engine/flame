import 'dart:ui';
import 'package:flame/effects.dart';

/// This effect controller invokes the [callback] function and then immediately
/// finishes. Use it as part of a more complex effect to insert callbacks at
/// certain parts of that effect.
class CallbackController extends DurationEffectController {
  /// Creates a controller that invokes the given [callback] function.
  /// The [progress] parameter specifies the progress level of the effect at the
  /// time when the callback is invoked. It is the responsibility of the user to
  /// ensure that this progress level is contiguous with respect to the progress
  /// of the overall effect.
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
