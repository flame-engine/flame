import 'package:flame/extensions.dart';
import 'package:flame/src/events/messages/event.dart';
import 'package:flutter/gestures.dart';

class DragEndEvent extends Event {
  DragEndEvent(this.pointerId, DragEndDetails details)
    : velocity = details.velocity.pixelsPerSecond.toVector2();

  final int pointerId;

  final Vector2 velocity;

  @override
  String toString() =>
      'DragEndEvent(pointerId: $pointerId, velocity: $velocity)';
}
