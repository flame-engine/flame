import 'package:flame/extensions.dart';
import 'package:flame/src/events/messages/position_event.dart';
import 'package:flutter/gestures.dart';

class DragUpdateEvent extends PositionEvent {
  DragUpdateEvent(this.pointerId, DragUpdateDetails details)
      : super(
          canvasPosition: details.localPosition.toVector2(),
          devicePosition: details.globalPosition.toVector2(),
        );

  final int pointerId;

  @override
  Vector2 get localPosition {
    return renderingTrace.isEmpty? _oobPoint : renderingTrace.last;
  }

  static final _oobPoint = Vector2.all(double.nan);
}
