import 'package:flutter/gestures.dart';

import '../../extensions.dart';

abstract class _BaseInfo<T> {
  final T raw;

  _BaseInfo(this.raw);
}

abstract class _PositionInfo<T> extends _BaseInfo<T> {
  final Vector2 position;
  final Vector2 gameWidgetPosition;
  final Vector2 globalPosition;

  _PositionInfo(
    this.position,
    this.gameWidgetPosition,
    this.globalPosition,
    T raw,
  ) : super(raw);
}

abstract class _LocalPositionOnlyInfo<T> extends _BaseInfo<T> {
  final Vector2 position;
  final Vector2 gameWidgetPosition;

  _LocalPositionOnlyInfo(
    this.position,
    this.gameWidgetPosition,
    T raw,
  ) : super(raw);
}

class TapDownInfo extends _PositionInfo<TapDownDetails> {
  TapDownInfo(
    Vector2 position,
    Vector2 gameWidgetPosition,
    Vector2 globalPosition,
    TapDownDetails raw,
  ) : super(position, gameWidgetPosition, globalPosition, raw);
}

class TapUpInfo extends _PositionInfo<TapUpDetails> {
  TapUpInfo(
    Vector2 position,
    Vector2 gameWidgetPosition,
    Vector2 globalPosition,
    TapUpDetails raw,
  ) : super(position, gameWidgetPosition, globalPosition, raw);
}

class LongPressStartInfo extends _PositionInfo<LongPressStartDetails> {
  LongPressStartInfo(
    Vector2 position,
    Vector2 gameWidgetPosition,
    Vector2 globalPosition,
    LongPressStartDetails raw,
  ) : super(position, gameWidgetPosition, globalPosition, raw);
}

class LongPressEndInfo extends _PositionInfo<LongPressEndDetails> {
  final Vector2 velocity;

  LongPressEndInfo(
    Vector2 position,
    Vector2 gameWidgetPosition,
    Vector2 globalPosition,
    this.velocity,
    LongPressEndDetails raw,
  ) : super(position, gameWidgetPosition, globalPosition, raw);
}

class LongPressMoveUpdateInfo
    extends _PositionInfo<LongPressMoveUpdateDetails> {
  LongPressMoveUpdateInfo(
    Vector2 position,
    Vector2 gameWidgetPosition,
    Vector2 globalPosition,
    LongPressMoveUpdateDetails raw,
  ) : super(position, gameWidgetPosition, globalPosition, raw);
}

class ForcePressInfo extends _PositionInfo<ForcePressDetails> {
  final double pressure;

  ForcePressInfo(
    Vector2 position,
    Vector2 gameWidgetPosition,
    Vector2 globalPosition,
    this.pressure,
    ForcePressDetails raw,
  ) : super(position, gameWidgetPosition, globalPosition, raw);
}

// TODO(erick) This class, and the next one has a bunch of info, we need to check the ones
// that could wrapped directly by the info class
class PointerScrollInfo extends _LocalPositionOnlyInfo<PointerScrollEvent> {
  final Vector2 scrollDelta;

  PointerScrollInfo(
    Vector2 position,
    Vector2 gameWidgetPosition,
    this.scrollDelta,
    PointerScrollEvent raw,
  ) : super(position, gameWidgetPosition, raw);
}

class PointerHoverInfo extends _LocalPositionOnlyInfo<PointerHoverEvent> {
  PointerHoverInfo(
    Vector2 position,
    Vector2 gameWidgetPosition,
    PointerHoverEvent raw,
  ) : super(position, gameWidgetPosition, raw);
}

class DragDownInfo extends _PositionInfo<DragDownDetails> {
  DragDownInfo(
    Vector2 position,
    Vector2 gameWidgetPosition,
    Vector2 globalPosition,
    DragDownDetails raw,
  ) : super(position, gameWidgetPosition, globalPosition, raw);
}

class DragStartInfo extends _PositionInfo<DragStartDetails> {
  DragStartInfo(
    Vector2 position,
    Vector2 gameWidgetPosition,
    Vector2 globalPosition,
    DragStartDetails raw,
  ) : super(position, gameWidgetPosition, globalPosition, raw);
}

class DragUpdateInfo extends _PositionInfo<DragUpdateDetails> {
  final Vector2 delta;
  DragUpdateInfo(
    Vector2 position,
    Vector2 gameWidgetPosition,
    Vector2 globalPosition,
    this.delta,
    DragUpdateDetails raw,
  ) : super(position, gameWidgetPosition, globalPosition, raw);
}

class DragEndInfo extends _BaseInfo<DragEndDetails> {
  final Vector2 velocity;
  final double? primaryVelocity;

  DragEndInfo(this.velocity, this.primaryVelocity, DragEndDetails raw)
      : super(raw);
}

class ScaleStartInfo extends _BaseInfo<ScaleStartDetails> {
  final Vector2 focalPoint;
  final int pointerCount;

  ScaleStartInfo(this.focalPoint, this.pointerCount, ScaleStartDetails raw)
      : super(raw);
}

class ScaleEndInfo extends _BaseInfo<ScaleEndDetails> {
  final Vector2 velocity;
  final int pointerCount;

  ScaleEndInfo(this.velocity, this.pointerCount, ScaleEndDetails raw)
      : super(raw);
}

class ScaleUpdateInfo extends _BaseInfo<ScaleUpdateDetails> {
  final Vector2 focalPoint;
  final int pointerCount;
  final double rotation;
  final Vector2 scale;

  ScaleUpdateInfo(
    this.focalPoint,
    this.pointerCount,
    this.rotation,
    this.scale,
    ScaleUpdateDetails raw,
  ) : super(raw);
}
