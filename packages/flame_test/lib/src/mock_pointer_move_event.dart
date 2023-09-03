import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/gestures.dart' as flutter;

PointerMoveEvent createMouseMoveEvent({
  required Game game,
  int? pointerId,
  Vector2? position,
  Vector2? delta,
  Duration? timestamp,
}) {
  return PointerMoveEvent(
    pointerId ?? 1,
    game,
    flutter.PointerMoveEvent(
      timeStamp: timestamp ?? Duration.zero,
      position: position?.toOffset() ?? Offset.zero,
      delta: delta?.toOffset() ?? Offset.zero,
    ),
  );
}