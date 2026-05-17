import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/gestures.dart' as flutter;

ScrollEvent createScrollEvent({
  required Game game,
  Vector2? position,
  Vector2? scrollDelta,
}) {
  return ScrollEvent(
    game,
    flutter.PointerScrollEvent(
      position: position?.toOffset() ?? Offset.zero,
      scrollDelta: scrollDelta?.toOffset() ?? Offset.zero,
    ),
  );
}
