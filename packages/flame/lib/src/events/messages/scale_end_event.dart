import 'package:flame/extensions.dart';
import 'package:flame/src/events/messages/event.dart';
import 'package:flutter/gestures.dart';

/// Event propagated through the Flame engine when a scale gesture ends.
class ScaleEndEvent extends Event<ScaleEndDetails> {
  ScaleEndEvent(this.pointerId, ScaleEndDetails details)
    : velocity = details.velocity.pixelsPerSecond.toVector2(),
      super(raw: details);

  /// The unique identifier of the scale gesture.
  final int pointerId;

  /// The velocity of the fingers at the end of the scale gesture.
  final Vector2 velocity;

  @override
  String toString() =>
      'ScaleEndEvent(pointerId: $pointerId, velocity: $velocity)';
}
