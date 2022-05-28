import 'package:flame/src/effects/controllers/speed_effect_controller.dart';

/// Interface implemented by several other Effect classes. This interface is
/// required by [SpeedEffectController]: it allows that controller to compute
/// the "length" of the effect, and divide by the speed in order to get the
/// desired duration of the effect.
///
/// Use this interface for any effect that you want to be compatible with the
/// [SpeedEffectController].
abstract class MeasurableEffect {
  /// Calculate the "measure" of the effect, which is the effect's distance
  /// from min to max progress. The "measure" is any property for which the
  /// notion of _speed_ is well-defined.
  ///
  /// This method will be called at the start of the effect, but after the
  /// Effect's `onStart` callback. It will be called again after the effect is
  /// reset.
  double measure();
}
