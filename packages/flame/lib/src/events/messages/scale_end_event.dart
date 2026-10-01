import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/gestures.dart';

/// Event propagated through the Flame engine when a scale gesture ends.
class ScaleEndEvent(
  /// The unique identifier of the scale gesture.
  final int pointerId,
  ScaleEndDetails details,
) extends Event<ScaleEndDetails> {
  this : super(raw: details);

  /// The velocity of the fingers at the end of the scale gesture.
  final Vector2 velocity = details.velocity.pixelsPerSecond.toVector2();

  @override
  String toString() =>
      'ScaleEndEvent(pointerId: $pointerId, velocity: $velocity)';
}
