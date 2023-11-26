import 'package:flame/extensions.dart';
import 'package:flame/src/events/messages/displacement_event.dart';
import 'package:flutter/gestures.dart';

class DragUpdateEvent extends DisplacementEvent {
  DragUpdateEvent(this.pointerId, super.game, DragUpdateDetails details)
      : timestamp = details.sourceTimeStamp ?? Duration.zero,
        super(
          deviceStartPosition: details.globalPosition.toVector2(),
          deviceEndPosition:
              details.globalPosition.toVector2() + details.delta.toVector2(),
        );

  final int pointerId;
  final Duration timestamp;

  @Deprecated('use localDelta instead; will be removed in version 1.12.0')
  Vector2 get delta => localDelta;

  Vector2 get localDelta {
    final start = localStartPosition;
    final end = localEndPosition;
    if (end.isNaN || start.isNaN) {
      print('s $start , e $end');
      return Vector2.zero();
    }

    return end - start;
  }
  // add other deltas

  @override
  String toString() => 'DragUpdateEvent(devicePosition: $deviceStartPosition, '
      'canvasPosition: $canvasStartPosition, '
      'delta: $localDelta, '
      'pointerId: $pointerId, timestamp: $timestamp)';
}
