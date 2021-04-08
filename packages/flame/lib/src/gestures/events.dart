import 'package:flutter/gestures.dart';

import '../../extensions.dart';

abstract class BaseInfo<T> {
  final Vector2 position;
  final T raw;

  BaseInfo(this.position, this.raw);
}

class TapDownInfo extends BaseInfo<TapDownDetails> {
  TapDownInfo(Vector2 position, TapDownDetails raw) : super(position, raw);
}

class TapUpInfo extends BaseInfo<TapUpDetails> {
  TapUpInfo(Vector2 position, TapUpDetails raw) : super(position, raw);
}

class LongPressStartInfo extends BaseInfo<LongPressStartDetails> {
  LongPressStartInfo(
    Vector2 position,
    LongPressStartDetails raw,
  ) : super(position, raw);
}

class LongPressEndInfo extends BaseInfo<LongPressEndDetails> {
  final Velocity velocity;

  LongPressEndInfo(
    Vector2 position,
    this.velocity,
    LongPressEndDetails raw,
  ) : super(position, raw);
}

class LongPressMoveUpdateInfo extends BaseInfo<LongPressMoveUpdateDetails> {
  LongPressMoveUpdateInfo(
    Vector2 position,
    LongPressMoveUpdateDetails raw,
  ) : super(position, raw);
}

class ForcePressInfo extends BaseInfo<ForcePressDetails> {
  final double pressure;

  ForcePressInfo(
    Vector2 position,
    this.pressure,
    ForcePressDetails raw,
  ) : super(position, raw);
}

// TODO(erick) This class, and the next one has a bunch of info, we need to check the ones
// that could wrapped directly by the info class
class PointerScrollInfo extends BaseInfo<PointerScrollEvent> {
  final Vector2 scrollDelta;

  PointerScrollInfo(Vector2 position, this.scrollDelta, PointerScrollEvent raw)
      : super(position, raw);
}

class PointerHoverInfo extends BaseInfo<PointerHoverEvent> {
  PointerHoverInfo(Vector2 position, PointerHoverEvent raw)
      : super(position, raw);
}

class DragDownInfo extends BaseInfo<DragDownDetails> {
  DragDownInfo(Vector2 position, DragDownDetails raw) : super(position, raw);
}

class DragStartInfo extends BaseInfo<DragStartDetails> {
  DragStartInfo(Vector2 position, DragStartDetails raw) : super(position, raw);
}

class DragUpdateInfo extends BaseInfo<DragUpdateDetails> {
  final Vector2 delta;
  DragUpdateInfo(Vector2 position, this.delta, DragUpdateDetails raw)
      : super(position, raw);
}

class DragEndInfo {
  final Velocity velocity;
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
  final Velocity velocity;
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
