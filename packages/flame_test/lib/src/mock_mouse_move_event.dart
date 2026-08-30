import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/gestures.dart' as flutter;

MouseMoveEvent createMouseMoveEvent({
  required Game game,
  int? pointerId,
  Vector2? position,
  Vector2? delta,
  Duration? timestamp,
}) {
  return MouseMoveEvent(
    pointerId ?? 1,
    game,
    flutter.PointerHoverEvent(
      timeStamp: timestamp ?? Duration.zero,
      position: position?.toOffset() ?? Offset.zero,
      delta: delta?.toOffset() ?? Offset.zero,
    ),
  );
}
