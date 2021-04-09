import 'package:flutter/gestures.dart';

import '../../extensions.dart';

abstract class BaseInfo<T> {
  final T raw;

  BaseInfo(this.raw);
}

abstract class PositionInfo<T> extends BaseInfo<T> {
  final Vector2 position;
  final Vector2 gameWidgetPosition;
  final Vector2 globalPosition;

  PositionInfo(
    this.position,
    this.gameWidgetPosition,
    this.globalPosition,
    T raw,
  ) : super(raw);
}

class TapDownInfo extends PositionInfo<TapDownDetails> {
  TapDownInfo(
    Vector2 position,
    Vector2 gameWidgetPosition,
    Vector2 globalPosition,
    TapDownDetails raw,
  ) : super(position, gameWidgetPosition, globalPosition, raw);
}

class TapUpInfo extends PositionInfo<TapUpDetails> {
  TapUpInfo(
    Vector2 position,
    Vector2 gameWidgetPosition,
    Vector2 globalPosition,
    TapUpDetails raw,
  ) : super(position, gameWidgetPosition, globalPosition, raw);
}

class LongPressStartInfo extends PositionInfo<LongPressStartDetails> {
  LongPressStartInfo(
    Vector2 position,
    Vector2 gameWidgetPosition,
    Vector2 globalPosition,
    LongPressStartDetails raw,
  ) : super(position, gameWidgetPosition, globalPosition, raw);
}

class LongPressEndInfo extends PositionInfo<LongPressEndDetails> {
  final Vector2 velocity;

  LongPressEndInfo(
    Vector2 position,
    Vector2 gameWidgetPosition,
    Vector2 globalPosition,
    this.velocity,
    LongPressEndDetails raw,
  ) : super(position, gameWidgetPosition, globalPosition, raw);
}

class LongPressMoveUpdateInfo extends PositionInfo<LongPressMoveUpdateDetails> {
  LongPressMoveUpdateInfo(
    Vector2 position,
    Vector2 gameWidgetPosition,
    Vector2 globalPosition,
    LongPressMoveUpdateDetails raw,
  ) : super(position, gameWidgetPosition, globalPosition, raw);
}

class ForcePressInfo extends PositionInfo<ForcePressDetails> {
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
class PointerScrollInfo extends BaseInfo<PointerScrollEvent> {
  final Vector2 position;
  final Vector2 gameWidgetPosition;
  final Vector2 scrollDelta;

  PointerScrollInfo(
    this.position,
    this.gameWidgetPosition,
    this.scrollDelta,
    PointerScrollEvent raw,
  ) : super(raw);
}

class PointerHoverInfo extends BaseInfo<PointerHoverEvent> {
  final Vector2 position;
  final Vector2 gameWidgetPosition;

  PointerHoverInfo(
    this.position,
    this.gameWidgetPosition,
    PointerHoverEvent raw,
  ) : super(raw);
}

class DragDownInfo extends PositionInfo<DragDownDetails> {
  DragDownInfo(
    Vector2 position,
    Vector2 gameWidgetPosition,
    Vector2 globalPosition,
    DragDownDetails raw,
  ) : super(position, gameWidgetPosition, globalPosition, raw);
}

class DragStartInfo extends PositionInfo<DragStartDetails> {
  DragStartInfo(
    Vector2 position,
    Vector2 gameWidgetPosition,
    Vector2 globalPosition,
    DragStartDetails raw,
  ) : super(position, gameWidgetPosition, globalPosition, raw);
}

class DragUpdateInfo extends PositionInfo<DragUpdateDetails> {
  final Vector2 delta;
  DragUpdateInfo(
    Vector2 position,
    Vector2 gameWidgetPosition,
    Vector2 globalPosition,
    this.delta,
    DragUpdateDetails raw,
  ) : super(position, gameWidgetPosition, globalPosition, raw);
}

class DragEndInfo {
  final Vector2 velocity;
  final double? primaryVelocity;
  final DragEndDetails raw;

  DragEndInfo(this.velocity, this.primaryVelocity, this.raw);
}

class ScaleStartInfo {
  final Vector2 focalPoint;
  final int pointerCount;
  final ScaleStartDetails raw;

  ScaleStartInfo(this.focalPoint, this.pointerCount, this.raw);
}

class ScaleEndInfo {
  final Vector2 velocity;
  final int pointerCount;
  final ScaleEndDetails raw;

  ScaleEndInfo(this.velocity, this.pointerCount, this.raw);
}

class ScaleUpdateInfo {
  final Vector2 focalPoint;
  final int pointerCount;
  final double rotation;
  final double horizontalScale;
  final double verticalScale;
  final ScaleUpdateDetails raw;

  ScaleUpdateInfo(
    this.focalPoint,
    this.pointerCount,
    this.rotation,
    this.horizontalScale,
    this.verticalScale,
    this.raw,
  );
}
