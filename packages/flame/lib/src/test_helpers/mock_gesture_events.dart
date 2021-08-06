import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/gestures.dart';

TapDownInfo createTapDownEvent(
  Game game, {
  Offset? globalPosition,
  Offset? localPosition,
}) {
  return TapDownInfo.fromDetails(
    game,
    TapDownDetails(
      localPosition: localPosition ?? Offset.zero,
      globalPosition: globalPosition ?? Offset.zero,
    ),
  );
}
