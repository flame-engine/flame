import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';

ForcePressEvent createForcePressEvent({
  required Game game,
  Offset? globalPosition,
  Offset? localPosition,
  double? pressure,
}) {
  return ForcePressEvent(
    game,
    ForcePressDetails(
      globalPosition: globalPosition ?? Offset.zero,
      localPosition: localPosition ?? globalPosition ?? Offset.zero,
      pressure: pressure ?? 0.5,
    ),
  );
}
