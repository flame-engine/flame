import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/src/events/messages/position_event.dart';
import 'package:flutter/gestures.dart' as flutter;

/// Event fired when a pointer scroll (mouse wheel) occurs.
///
/// This event includes scroll delta information in addition to the position
/// where the scroll occurred.
class ScrollEvent extends PositionEvent<flutter.PointerScrollEvent> {
  ScrollEvent(
    super.game,
    flutter.PointerScrollEvent rawEvent,
  ) : scrollDelta = rawEvent.scrollDelta.toVector2(),
      super(
        raw: rawEvent,
        devicePosition: rawEvent.position.toVector2(),
      );

  /// The scroll delta in logical pixels.
  ///
  /// Positive values indicate scrolling down or to the right,
  /// negative values indicate scrolling up or to the left.
  final Vector2 scrollDelta;

  @override
  String toString() =>
      'ScrollEvent(devicePosition: $devicePosition, '
      'canvasPosition: $canvasPosition, '
      'scrollDelta: $scrollDelta)';

  factory ScrollEvent.fromPointerScrollEvent(
    Game game,
    flutter.PointerScrollEvent event,
  ) {
    return ScrollEvent(game, event);
  }
}
