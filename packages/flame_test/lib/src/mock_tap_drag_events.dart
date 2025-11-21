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

ScaleStartEvent createScaleStartEvents({
  required Game game,
  int? pointerId,
  PointerDeviceKind? kind,
  Offset? focalPoint,
  Offset? localFocalPoint,
  int? pointerCount,
}) {
  return ScaleStartEvent(
    pointerId ?? 1,
    game,
    ScaleStartDetails(
      focalPoint: focalPoint ?? Offset.zero,
      localFocalPoint: localFocalPoint ?? Offset.zero,
      pointerCount: pointerCount ?? 1,
    ),
  );
}

ScaleUpdateEvent createScaleUpdateEvents({
  required Game game,
  int? pointerId,
  PointerDeviceKind? kind,
  Offset? localFocalPoint,
  Offset? focalPoint,
  double? scale,
  double? horizontalScale,
  double? verticalScale,
  double? rotation,
  int? pointerCount,
  Offset? focalPointDelta,
}) {
  return ScaleUpdateEvent(
    pointerId ?? 1,
    game,
    ScaleUpdateDetails(
      localFocalPoint: localFocalPoint ?? Offset.zero,
      focalPoint: focalPoint ?? Offset.zero,
      scale: scale ?? 1,
      horizontalScale: horizontalScale ?? 1,
      verticalScale: verticalScale ?? 1,
      rotation: rotation ?? 0,
      pointerCount: pointerCount ?? 1,
      focalPointDelta: focalPointDelta ?? Offset.zero,
    ),
  );
}
