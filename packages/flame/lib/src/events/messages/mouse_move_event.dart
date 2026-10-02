import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';

class MouseMoveEvent(
  final int pointerId,
  super.game,
  PointerHoverEvent rawEvent,
) extends PositionEvent<PointerHoverEvent> {
  this
    : super(
        raw: rawEvent,
        devicePosition: rawEvent.position.toVector2(),
      );

  final Duration timestamp = rawEvent.timeStamp;
  final Vector2 delta = rawEvent.delta.toVector2();

  static final _nanPoint = Vector2.all(double.nan);

  @override
  Vector2 get localPosition {
    return renderingTrace.isEmpty ? _nanPoint : renderingTrace.last;
  }

  @override
  String toString() =>
      'MouseMoveEvent(devicePosition: $devicePosition, '
      'canvasPosition: $canvasPosition, '
      'delta: $delta, '
      'pointerId: $pointerId, timestamp: $timestamp)';

  factory MouseMoveEvent.fromPointerHoverEvent(
    Game game,
    PointerHoverEvent event,
  ) {
    return MouseMoveEvent(
      event.pointer,
      game,
      event,
    );
  }
}
