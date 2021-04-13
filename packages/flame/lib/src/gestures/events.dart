import 'package:flutter/gestures.dart';

import '../../extensions.dart';
import '../game/game.dart';

class EventPosition {
  final Game _game;
  final Offset _localPosition;
  final Offset? _globalPosition;

  late final Vector2 game = _game.projectCoordinates(_localPosition);
  late final Vector2 widget = _localPosition.toVector2();
  late final Vector2 global = _globalPosition?.toVector2() ??
      _game.convertLocalToGlobalCoordinate(_localPosition.toVector2());

  EventPosition(this._game, this._localPosition, this._globalPosition);
}

abstract class _BaseInfo<T> {
  final T raw;

  _BaseInfo(this.raw);
}

abstract class _PositionInfo<T> extends _BaseInfo<T> {
  final Game _game;
  final Offset _position;
  final Offset? _globalPosition;

  late final position = EventPosition(
    _game,
    _position,
    _globalPosition,
  );

  _PositionInfo(
    this._game,
    this._position,
    this._globalPosition,
    T raw,
  ) : super(raw);
}

class TapDownInfo extends _PositionInfo<TapDownDetails> {
  TapDownInfo.fromDetails(
    Game game,
    TapDownDetails raw,
  ) : super(game, raw.localPosition, raw.globalPosition, raw);
}

class TapUpInfo extends _PositionInfo<TapUpDetails> {
  TapUpInfo.fromDetails(
    Game game,
    TapUpDetails raw,
  ) : super(game, raw.localPosition, raw.globalPosition, raw);
}

class LongPressStartInfo extends _PositionInfo<LongPressStartDetails> {
  LongPressStartInfo.fromDetails(
    Game game,
    LongPressStartDetails raw,
  ) : super(game, raw.localPosition, raw.globalPosition, raw);
}

class LongPressEndInfo extends _PositionInfo<LongPressEndDetails> {
  late final Vector2 velocity =
      _game.scaleCoordinate(raw.velocity.pixelsPerSecond);

  LongPressEndInfo.fromDetails(
    Game game,
    LongPressEndDetails raw,
  ) : super(game, raw.localPosition, raw.globalPosition, raw);
}

class LongPressMoveUpdateInfo
    extends _PositionInfo<LongPressMoveUpdateDetails> {
  LongPressMoveUpdateInfo.fromDetails(
    Game game,
    LongPressMoveUpdateDetails raw,
  ) : super(game, raw.localPosition, raw.globalPosition, raw);
}

class ForcePressInfo extends _PositionInfo<ForcePressDetails> {
  late final double pressure = raw.pressure;

  ForcePressInfo.fromDetails(
    Game game,
    ForcePressDetails raw,
  ) : super(game, raw.localPosition, raw.globalPosition, raw);
}

class PointerScrollInfo extends _PositionInfo<PointerScrollEvent> {
  late final Vector2 scrollDelta = _game.scaleCoordinate(raw.scrollDelta);

  PointerScrollInfo.fromDetails(
    Game game,
    PointerScrollEvent raw,
  ) : super(game, raw.localPosition, null, raw);
}

class PointerHoverInfo extends _PositionInfo<PointerHoverEvent> {
  PointerHoverInfo.fromDetails(
    Game game,
    PointerHoverEvent raw,
  ) : super(game, raw.localPosition, null, raw);
}

class DragDownInfo extends _PositionInfo<DragDownDetails> {
  DragDownInfo.fromDetails(
    Game game,
    DragDownDetails raw,
  ) : super(game, raw.localPosition, raw.globalPosition, raw);
}

class DragStartInfo extends _PositionInfo<DragStartDetails> {
  DragStartInfo.fromDetails(
    Game game,
    DragStartDetails raw,
  ) : super(game, raw.localPosition, raw.globalPosition, raw);
}

class DragUpdateInfo extends _PositionInfo<DragUpdateDetails> {
  late final Vector2 delta = _game.scaleCoordinate(raw.delta);

  DragUpdateInfo.fromDetails(
    Game game,
    DragUpdateDetails raw,
  ) : super(game, raw.localPosition, raw.globalPosition, raw);
}

class DragEndInfo extends _BaseInfo<DragEndDetails> {
  final Game _game;
  late final Vector2 velocity =
      _game.scaleCoordinate(raw.velocity.pixelsPerSecond);
  double? get primaryVelocity => raw.primaryVelocity;

  DragEndInfo.fromDetails(
    this._game,
    DragEndDetails raw,
  ) : super(raw);
}

class ScaleStartInfo extends _PositionInfo<ScaleStartDetails> {
  int get pointerCount => raw.pointerCount;

  ScaleStartInfo.fromDetails(
    Game game,
    ScaleStartDetails raw,
  ) : super(game, raw.localFocalPoint, raw.focalPoint, raw);
}

class ScaleEndInfo extends _BaseInfo<ScaleEndDetails> {
  final Game _game;
  late final Vector2 velocity =
      _game.scaleCoordinate(raw.velocity.pixelsPerSecond);
  int get pointerCount => raw.pointerCount;

  ScaleEndInfo.fromDetails(
    this._game,
    ScaleEndDetails raw,
  ) : super(raw);
}

class ScaleUpdateInfo extends _PositionInfo<ScaleUpdateDetails> {
  int get pointerCount => raw.pointerCount;
  double get rotation => raw.rotation;
  late final Vector2 scale =
      _game.scaleCoordinate(Offset(raw.horizontalScale, raw.verticalScale));

  ScaleUpdateInfo.fromDetails(
    Game game,
    ScaleUpdateDetails raw,
  ) : super(game, raw.localFocalPoint, raw.focalPoint, raw);
}
