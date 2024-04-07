import 'dart:math';

/// [TapConfig] is used to expose specific configurations
/// related to the tap dispatcher.
final class TapConfig {
  TapConfig._();

  static double _longTapDelay = _defaultLongTapDelay;

  /// The delay (in seconds) after which a tap is considered a long tap.
  static double get longTapDelay => _longTapDelay;

  /// Set the delay (in seconds) after which a tap is considered a long tap.
  /// Same games may want to change the long tap delay to better
  /// fit their needs or accessibility requirements.
  static set longTapDelay(double value) {
    _longTapDelay = max(_minLongTapDelay, value);
  }

  /// Min delay to long tap delay is defined below.
  /// Values too low don't make sense because they
  /// would be basically a regular tap.
  static const double _minLongTapDelay = 0.150;

  /// Default long tap delay is 0.3 seconds.
  static const double _defaultLongTapDelay = 0.3;
}
