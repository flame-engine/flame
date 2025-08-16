import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/src/events/messages/position_event.dart';
import 'package:flutter/gestures.dart' as flutter;

class PointerMoveEvent extends PositionEvent {
  PointerMoveEvent(
    this.pointerId,
    super.game,
    flutter.PointerHoverEvent rawEvent,
  ) : timestamp = rawEvent.timeStamp,
      delta = rawEvent.delta.toVector2(),
      super(
        devicePosition: rawEvent.position.toVector2(),
      );

  final int pointerId;
  final Duration timestamp;
  final Vector2 delta;

  static final _nanPoint = Vector2.all(double.nan);

  @override
  Vector2 get localPosition {
    return renderingTrace.isEmpty ? _nanPoint : renderingTrace.last;
  }

  @override
  String toString() =>
      'PointerMoveEvent(devicePosition: $devicePosition, '
      'canvasPosition: $canvasPosition, '
      'delta: $delta, '
      'pointerId: $pointerId, timestamp: $timestamp)';

  factory PointerMoveEvent.fromPointerHoverEvent(
    Game game,
    flutter.PointerHoverEvent event,
  ) {
    return PointerMoveEvent(
      event.pointer,
      game,
      event,
    );
  }
}
