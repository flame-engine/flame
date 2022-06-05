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

TapUpInfo createTapUpEvent(
  Game game, {
  Offset? globalPosition,
  Offset? localPosition,
  PointerDeviceKind kind = PointerDeviceKind.mouse,
}) {
  return TapUpInfo.fromDetails(
    game,
    TapUpDetails(
      localPosition: localPosition ?? Offset.zero,
      globalPosition: globalPosition ?? Offset.zero,
      kind: PointerDeviceKind.mouse,
    ),
  );
}
