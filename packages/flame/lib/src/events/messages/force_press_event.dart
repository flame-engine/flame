import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/gestures.dart';

/// The event propagated through the Flame engine during a force press gesture,
/// i.e. a touch that also reports how hard the user is pressing.
///
/// The same event class is used for all four phases of the gesture (start,
/// peak, update and end) because Flutter describes every one of them with a
/// single [ForcePressDetails] object.
///
/// This is a [PositionEvent], where the position is the point of contact.
///
/// Note that force press requires a pressure-sensitive screen: Apple's 3D
/// Touch, which shipped on the iPhone 6s through the iPhone XS, or a small
/// number of Android devices. On any other device the gesture is never
/// recognized and these events are never delivered.
class ForcePressEvent extends PositionEvent<ForcePressDetails> {
  ForcePressEvent(super.game, ForcePressDetails details)
    : pressure = details.pressure,
      super(
        raw: details,
        devicePosition: details.globalPosition.toVector2(),
      );

  /// How hard the user is pressing, normalized to the `[0, 1]` range across
  /// the pressure range that the device reports.
  ///
  /// The gesture is only recognized once this value crosses the recognizer's
  /// `startPressure` (`0.4` by default), and `onForcePressPeak` fires when it
  /// crosses `peakPressure` (`0.85` by default).
  final double pressure;

  @override
  String toString() =>
      'ForcePressEvent(canvasPosition: $canvasPosition, '
      'devicePosition: $devicePosition, '
      'pressure: $pressure)';
}
