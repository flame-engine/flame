import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/gestures.dart';

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
