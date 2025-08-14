import 'package:flame/components.dart';
import 'package:flame/src/events/messages/location_context_event.dart';
import 'package:flame/src/game/game.dart';

/// Base class for events that originate at some point on the screen. These
/// include: tap events, scale events, etc.
///
/// This class includes properties that describe the position where the event
/// has occurred.
abstract class PositionEvent extends LocationContextEvent<Vector2> {
  PositionEvent(this._game, {required this.devicePosition});
  final Game _game;

  /// Event position in the coordinate space of the device -- either the phone,
  /// or the browser window, or the app.
  ///
  /// If the game runs in a full-screen mode, then this would be equal to the
  /// [canvasPosition]. Otherwise, the [devicePosition] is the Flutter-level
  /// global position.
  final Vector2 devicePosition;

  /// Event position in the coordinate space of the game widget, i.e. relative
  /// to the game canvas.
  ///
  /// This could be considered the Flame-level global position.
  late final Vector2 canvasPosition = _game.convertGlobalToLocalCoordinate(
    devicePosition,
  );

  /// Event position in the local coordinate space of the current component.
  ///
  /// This property is only accessible when the event is being propagated to
  /// the components via [deliverAtPoint]. It is an error to try to read this
  /// property at other times.
  Vector2 get localPosition => renderingTrace.last;

  @override
  Iterable<Component> collectApplicableChildren({
    required Component rootComponent,
  }) {
    return rootComponent.componentsAtPoint(canvasPosition, renderingTrace);
  }
}
