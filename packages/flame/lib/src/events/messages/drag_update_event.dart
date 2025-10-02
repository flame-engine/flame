import 'package:flame/extensions.dart';
import 'package:flame/src/events/messages/displacement_event.dart';
import 'package:flutter/gestures.dart';

class DragUpdateEvent extends DisplacementEvent<DragUpdateDetails> {
  DragUpdateEvent(this.pointerId, super.game, DragUpdateDetails details)
    : timestamp = details.sourceTimeStamp ?? Duration.zero,
      super(
        raw: details,
        deviceStartPosition: details.globalPosition.toVector2(),
        deviceEndPosition:
            details.globalPosition.toVector2() + details.delta.toVector2(),
      );

  final int pointerId;
  final Duration timestamp;

  @override
  String toString() =>
      'DragUpdateEvent('
      'devicePosition: $deviceStartPosition, '
      'canvasPosition: $canvasStartPosition, '
      'delta: $localDelta, '
      'pointerId: $pointerId, '
      'timestamp: $timestamp'
      ')';
}
