import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';
import 'package:flame/gestures.dart';
import 'package:flame/extensions.dart';

TapDownInfo createTapDownEvent(
  Game game, {
  Offset? position,
  Offset? globalPosition,
}) {
  return TapDownInfo.fromDetails(
    game,
    TapDownDetails(
      localPosition: position ?? Offset.zero,
      globalPosition: globalPosition ?? Offset.zero,
    ),
  );
}
