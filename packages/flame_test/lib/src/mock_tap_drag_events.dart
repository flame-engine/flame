import 'package:flame/experimental.dart';
import 'package:flutter/gestures.dart';

TapDownEvent createTapDownEvents({
  int? pointerId,
  PointerDeviceKind? kind,
  Offset? globalPosition,
  Offset? localPosition,
}) {
  return TapDownEvent(
    pointerId ?? 1,
    TapDownDetails(
      localPosition: localPosition ?? Offset.zero,
      globalPosition: globalPosition ?? Offset.zero,
      kind: kind ?? PointerDeviceKind.touch,
    ),
  );
}

TapUpEvent createTapUpEvents({
  int? pointerId,
  PointerDeviceKind? kind,
  Offset? globalPosition,
  Offset? localPosition,
}) {
  return TapUpEvent(
    pointerId ?? 1,
    TapUpDetails(
      localPosition: localPosition ?? Offset.zero,
      globalPosition: globalPosition ?? Offset.zero,
      kind: kind ?? PointerDeviceKind.touch,
    ),
  );
}

DragStartEvent createDragStartEvents({
  int? pointerId,
  PointerDeviceKind? kind,
  Offset? globalPosition,
  Offset? localPosition,
}) {
  return DragStartEvent(
    pointerId ?? 1,
    DragStartDetails(
      localPosition: localPosition ?? Offset.zero,
      globalPosition: globalPosition ?? Offset.zero,
    ),
  );
}

DragUpdateEvent createDragUpdateEvents({
  int? pointerId,
  PointerDeviceKind? kind,
  Offset? globalPosition,
  Offset? localPosition,
}) {
  return DragUpdateEvent(
    pointerId ?? 1,
    DragUpdateDetails(
      localPosition: localPosition ?? Offset.zero,
      globalPosition: globalPosition ?? Offset.zero,
    ),
  );
}
