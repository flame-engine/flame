import 'package:flame/events.dart';
import 'package:flutter/gestures.dart';

/// Interface that must be implemented in order to be eligible to receive
/// events from a [MultiDragScaleGestureRecognizer].
///
/// Instead of implementing this class directly, consider using the
/// [ScaleCallbacks] mixin on a `Component` (or `Game`).
abstract class ScaleListener {
  /// The beginning of a scale operation.
  ///
  /// This event fires once two or more pointers are touching the screen and
  /// their movement exceeds the recognizer's scale threshold.
  void handleScaleStart(ScaleStartDetails details);

  /// The pointers taking part in the scale gesture have moved.
  ///
  /// This event occurs frequently during the gesture, reporting the current
  /// scale factors, the rotation and the focal point.
  void handleScaleUpdate(ScaleUpdateDetails details);

  /// Marks the end of a scale operation.
  ///
  /// This event fires once fewer than two pointers are left touching the
  /// screen.
  void handleScaleEnd(ScaleEndDetails details);
}
