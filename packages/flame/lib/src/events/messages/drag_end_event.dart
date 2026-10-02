import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/gestures.dart';

class DragEndEvent(final int pointerId, DragEndDetails details)
    extends Event<DragEndDetails> {
  this : super(raw: details);

  final Vector2 velocity = details.velocity.pixelsPerSecond.toVector2();

  @override
  String toString() =>
      'DragEndEvent(pointerId: $pointerId, velocity: $velocity)';
}
