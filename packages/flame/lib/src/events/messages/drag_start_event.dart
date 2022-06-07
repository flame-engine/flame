
import 'package:flame/extensions.dart';
import 'package:flame/src/events/messages/position_event.dart';
import 'package:flutter/gestures.dart';

class DragStartEvent extends PositionEvent {
  DragStartEvent(this.pointerId, DragDownDetails details)
      : super(
    canvasPosition: details.localPosition.toVector2(),
    devicePosition: details.globalPosition.toVector2(),
  );

  final int pointerId;
}
