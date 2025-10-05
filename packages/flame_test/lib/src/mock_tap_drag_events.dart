import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';

TapDownEvent createTapDownEvents({
  required Game game,
  int? pointerId,
  PointerDeviceKind? kind,
  Offset? globalPosition,
  Offset? localPosition,
}) {
  return TapDownEvent(
    pointerId ?? 1,
    game,
    TapDownDetails(
      localPosition: localPosition ?? Offset.zero,
      globalPosition: globalPosition ?? Offset.zero,
      kind: kind ?? PointerDeviceKind.touch,
    ),
  );
}

TapUpEvent createTapUpEvents({
  required Game game,
  int? pointerId,
  PointerDeviceKind? kind,
  Offset? globalPosition,
  Offset? localPosition,
}) {
  return TapUpEvent(
    pointerId ?? 1,
    game,
    TapUpDetails(
      localPosition: localPosition ?? Offset.zero,
      globalPosition: globalPosition ?? Offset.zero,
      kind: kind ?? PointerDeviceKind.touch,
    ),
  );
}

SecondaryTapDownEvent createSecondaryTapDownEvents({
  required Game game,
  PointerDeviceKind? kind,
  Offset? globalPosition,
  Offset? localPosition,
}) {
  return SecondaryTapDownEvent(
    game,
    TapDownDetails(
      localPosition: localPosition ?? Offset.zero,
      globalPosition: globalPosition ?? Offset.zero,
      kind: kind ?? PointerDeviceKind.touch,
    ),
  );
}

SecondaryTapUpEvent createSecondaryTapUpEvents({
  required Game game,
  PointerDeviceKind? kind,
  Offset? globalPosition,
  Offset? localPosition,
}) {
  return SecondaryTapUpEvent(
    game,
    TapUpDetails(
      localPosition: localPosition ?? Offset.zero,
      globalPosition: globalPosition ?? Offset.zero,
      kind: kind ?? PointerDeviceKind.touch,
    ),
  );
}

DragStartEvent createDragStartEvents({
  required Game game,
  int? pointerId,
  PointerDeviceKind? kind,
  Offset? globalPosition,
  Offset? localPosition,
}) {
  return DragStartEvent(
    pointerId ?? 1,
    game,
    DragStartDetails(
      localPosition: localPosition ?? Offset.zero,
      globalPosition: globalPosition ?? Offset.zero,
    ),
  );
}

DragUpdateEvent createDragUpdateEvents({
  required Game game,
  int? pointerId,
  PointerDeviceKind? kind,
  Offset? globalPosition,
  Offset? localPosition,
}) {
  return DragUpdateEvent(
    pointerId ?? 1,
    game,
    DragUpdateDetails(
      localPosition: localPosition ?? Offset.zero,
      globalPosition: globalPosition ?? Offset.zero,
    ),
  );
}
