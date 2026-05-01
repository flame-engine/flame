import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';

LongPressStartEvent createLongPressStartEvent({
  required Game game,
  int? pointerId,
  Offset? globalPosition,
  Offset? localPosition,
}) {
  return LongPressStartEvent(
    pointerId ?? 1,
    game,
    LongPressStartDetails(
      localPosition: localPosition ?? Offset.zero,
      globalPosition: globalPosition ?? Offset.zero,
    ),
  );
}

LongPressMoveUpdateEvent createLongPressMoveUpdateEvent({
  required Game game,
  int? pointerId,
  Offset? globalPosition,
  Offset? localPosition,
  Offset? offsetFromOrigin,
  Offset? localOffsetFromOrigin,
  Offset? previousGlobalPosition,
}) {
  return LongPressMoveUpdateEvent(
    pointerId ?? 1,
    game,
    LongPressMoveUpdateDetails(
      localPosition: localPosition ?? Offset.zero,
      globalPosition: globalPosition ?? Offset.zero,
      offsetFromOrigin: offsetFromOrigin ?? Offset.zero,
      localOffsetFromOrigin: localOffsetFromOrigin ?? Offset.zero,
    ),
    previousGlobalPosition: previousGlobalPosition ?? Offset.zero,
  );
}

LongPressEndEvent createLongPressEndEvent({
  required Game game,
  int? pointerId,
  Offset? globalPosition,
  Offset? localPosition,
  Velocity? velocity,
}) {
  return LongPressEndEvent(
    pointerId ?? 1,
    game,
    LongPressEndDetails(
      localPosition: localPosition ?? Offset.zero,
      globalPosition: globalPosition ?? Offset.zero,
      velocity: velocity ?? Velocity.zero,
    ),
  );
}

LongPressCancelEvent createLongPressCancelEvent({
  int? pointerId,
}) {
  return LongPressCancelEvent(pointerId ?? 1);
}
