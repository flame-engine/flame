import 'package:flutter/gestures.dart';

import '../../extensions.dart';
import '../game/mixins/game.dart';

/// [EventPosition] converts position based events to three different coordinate systems (global, local and game).
///
/// global: coordinate system relative to the entire app; same as `globalPosition` in Flutter
/// widget: coordinate system relative to the GameWidget widget; same as `localPosition` in Flutter
/// game: same as `widget` but also applies any transformations from the camera or viewport to the coordinate system
class EventPosition {
  final Game _game;
  final Offset _globalPosition;

  /// Coordinates of the event relative to the whole screen
  late final Vector2 global = _globalPosition.toVector2();

  /// Coordinates of the event relative to the game widget position/size
  late final Vector2 widget = _game.convertGlobalToLocalCoordinate(global);

  /// Coordinates of the event relative to the game position/size and transformations
  late final Vector2 game = _game.unprojectVector(widget);

  EventPosition(this._game, this._globalPosition);
}

/// [EventDelta] converts deltas based events to two different values (game and global).
///
/// [global]: this is the raw value received by the event without any scale applied to it; this is always the same as local because Flutter doesn't apply any scaling.
/// [game]: the scalled value applied all the game transformations.
class EventDelta {
  final Game _game;
  final Offset _delta;

  /// Raw value relative to the game transformations
  late final Vector2 global = _delta.toVector2();

  /// Scaled value relative to the game transformations
  late final Vector2 game = _game.unscaleVector(global);

  EventDelta(this._game, this._delta);
}

/// BaseInfo is the base class for Flame's input events.
/// This base class just wraps Flutter's [raw] attribute.
abstract class BaseInfo<T> {
  final T raw;

  BaseInfo(this.raw);
}

/// A more specialized wrapper of Flame's base class for input events.
/// It adds the [eventPosition] field and is used by all position based
/// events on Flame.
abstract class PositionInfo<T> extends BaseInfo<T> {
  final Game _game;
  final Offset _globalPosition;

  late final eventPosition = EventPosition(_game, _globalPosition);

  PositionInfo(
    this._game,
    this._globalPosition,
    T raw,
  ) : super(raw);
}

class TapDownInfo extends PositionInfo<TapDownDetails> {
  TapDownInfo.fromDetails(
    Game game,
    TapDownDetails raw,
  ) : super(game, raw.globalPosition, raw);
}

class TapUpInfo extends PositionInfo<TapUpDetails> {
  TapUpInfo.fromDetails(
    Game game,
    TapUpDetails raw,
  ) : super(game, raw.globalPosition, raw);
}

class LongPressStartInfo extends PositionInfo<LongPressStartDetails> {
  LongPressStartInfo.fromDetails(
    Game game,
    LongPressStartDetails raw,
  ) : super(game, raw.globalPosition, raw);
}

class LongPressEndInfo extends PositionInfo<LongPressEndDetails> {
  late final Vector2 velocity =
      _game.unscaleVector(raw.velocity.pixelsPerSecond.toVector2());

  LongPressEndInfo.fromDetails(
    Game game,
    LongPressEndDetails raw,
  ) : super(game, raw.globalPosition, raw);
}

class LongPressMoveUpdateInfo extends PositionInfo<LongPressMoveUpdateDetails> {
  LongPressMoveUpdateInfo.fromDetails(
    Game game,
    LongPressMoveUpdateDetails raw,
  ) : super(game, raw.globalPosition, raw);
}

class ForcePressInfo extends PositionInfo<ForcePressDetails> {
  late final double pressure = raw.pressure;

  ForcePressInfo.fromDetails(
    Game game,
    ForcePressDetails raw,
  ) : super(game, raw.globalPosition, raw);
}

class PointerScrollInfo extends PositionInfo<PointerScrollEvent> {
  late final EventDelta scrollDelta = EventDelta(_game, raw.scrollDelta);

  PointerScrollInfo.fromDetails(
    Game game,
    PointerScrollEvent raw,
  ) : super(game, raw.position, raw);
}

class PointerHoverInfo extends PositionInfo<PointerHoverEvent> {
  PointerHoverInfo.fromDetails(
    Game game,
    PointerHoverEvent raw,
  ) : super(game, raw.position, raw);
}

class DragDownInfo extends PositionInfo<DragDownDetails> {
  DragDownInfo.fromDetails(
    Game game,
    DragDownDetails raw,
  ) : super(game, raw.globalPosition, raw);
}

class DragStartInfo extends PositionInfo<DragStartDetails> {
  DragStartInfo.fromDetails(
    Game game,
    DragStartDetails raw,
  ) : super(game, raw.globalPosition, raw);
}

class DragUpdateInfo extends PositionInfo<DragUpdateDetails> {
  late final EventDelta delta = EventDelta(_game, raw.delta);

  DragUpdateInfo.fromDetails(
    Game game,
    DragUpdateDetails raw,
  ) : super(game, raw.globalPosition, raw);
}

class DragEndInfo extends BaseInfo<DragEndDetails> {
  final Game _game;
  late final Vector2 velocity =
      _game.unscaleVector(raw.velocity.pixelsPerSecond.toVector2());
  double? get primaryVelocity => raw.primaryVelocity;

  DragEndInfo.fromDetails(
    this._game,
    DragEndDetails raw,
  ) : super(raw);
}

class ScaleStartInfo extends PositionInfo<ScaleStartDetails> {
  int get pointerCount => raw.pointerCount;

  ScaleStartInfo.fromDetails(
    Game game,
    ScaleStartDetails raw,
  ) : super(game, raw.focalPoint, raw);
}

class ScaleEndInfo extends BaseInfo<ScaleEndDetails> {
  final Game _game;
  late final EventDelta velocity = EventDelta(
    _game,
    raw.velocity.pixelsPerSecond,
  );

  int get pointerCount => raw.pointerCount;

  ScaleEndInfo.fromDetails(
    this._game,
    ScaleEndDetails raw,
  ) : super(raw);
}

class ScaleUpdateInfo extends PositionInfo<ScaleUpdateDetails> {
  int get pointerCount => raw.pointerCount;
  double get rotation => raw.rotation;
  late final EventDelta scale = EventDelta(
    _game,
    Offset(raw.horizontalScale, raw.verticalScale),
  );

  ScaleUpdateInfo.fromDetails(
    Game game,
    ScaleUpdateDetails raw,
  ) : super(game, raw.focalPoint, raw);
}
