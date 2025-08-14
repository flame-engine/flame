import 'package:flame/components.dart';
import 'package:flame/src/events/messages/location_context_event.dart';
import 'package:flame/src/game/game.dart';

/// Location context for the Displacement Event.
///
/// This represents a user event that has a start and end locations, as the
/// ones that are represented by a [DisplacementEvent].
typedef DisplacementContext = ({Vector2 start, Vector2 end});

extension DisplacementContextDelta on DisplacementContext {
  /// Displacement delta
  Vector2 get delta => end - start;
}

/// Base class for events that contain two points on the screen, representing
/// some sort of movement (from a "start" to and "end") and having a "delta".
/// These include: drag events and (in the future) pointer move events.
///
/// This class includes properties that describe both positions where the event
/// has occurred (start and end) and the delta (i.e. displacement) represented
/// by the event.
abstract class DisplacementEvent
    extends LocationContextEvent<DisplacementContext> {
  DisplacementEvent(
    this._game, {
    required this.deviceStartPosition,
    required this.deviceEndPosition,
  });
  final Game _game;

  /// Event start position in the coordinate space of the device -- either the
  /// phone, or the browser window, or the app.
  ///
  /// If the game runs in a full-screen mode, then this would be equal to the
  /// [canvasStartPosition]. Otherwise, the [deviceStartPosition] is the
  /// Flutter-level global position.
  final Vector2 deviceStartPosition;

  /// Event start position in the coordinate space of the game widget, i.e.
  /// relative to the game canvas.
  ///
  /// This could be considered the Flame-level global position.
  late final Vector2 canvasStartPosition = _game.convertGlobalToLocalCoordinate(
    deviceStartPosition,
  );

  /// Event start position in the local coordinate space of the current
  /// component.
  ///
  /// This property is only accessible when the event is being propagated to
  /// the components via [deliverAtPoint]. It is an error to try to read this
  /// property at other times.
  Vector2 get localStartPosition => renderingTrace.last.start;

  /// Event end position in the coordinate space of the device -- either the
  /// phone, or the browser window, or the app.
  ///
  /// If the game runs in a full-screen mode, then this would be equal to the
  /// [canvasEndPosition]. Otherwise, the [deviceEndPosition] is the
  /// Flutter-level global position.
  final Vector2 deviceEndPosition;

  /// Event end position in the coordinate space of the game widget, i.e.
  /// relative to the game canvas.
  ///
  /// This could be considered the Flame-level global position.
  late final Vector2 canvasEndPosition = _game.convertGlobalToLocalCoordinate(
    deviceEndPosition,
  );

  /// Event end position in the local coordinate space of the current
  /// component.
  ///
  /// This property is only accessible when the event is being propagated to
  /// the components via [deliverAtPoint]. It is an error to try to read this
  /// property at other times.
  Vector2 get localEndPosition => renderingTrace.last.end;

  /// Event delta in the coordinate space of the device -- either the
  /// phone, or the browser window, or the app.
  ///
  /// If the game runs in a full-screen mode, then this would be equal to the
  /// [canvasDelta]. Otherwise, the [deviceDelta] is the
  /// Flutter-level global position.
  late final Vector2 deviceDelta = deviceEndPosition - deviceStartPosition;

  /// Event delta in the coordinate space of the game widget, i.e.
  /// relative to the game canvas.
  ///
  /// This could be considered the Flame-level global position.
  late final Vector2 canvasDelta = canvasEndPosition - canvasStartPosition;

  /// Event delta in the local coordinate space of the current component.
  ///
  /// This property is only accessible when the event is being propagated to
  /// the components via [deliverAtPoint]. It is an error to try to read this
  /// property at other times.
  Vector2 get localDelta => localEndPosition - localStartPosition;

  @override
  Iterable<Component> collectApplicableChildren({
    required Component rootComponent,
  }) {
    return rootComponent.componentsAtLocation(
      (
        start: canvasStartPosition,
        end: canvasEndPosition,
      ),
      renderingTrace,
      (transform, context) {
        final start = context.start;
        final transformedStart = transform.parentToLocal(start);

        final end = context.end;
        final transformedEnd = transform.parentToLocal(end);

        if (transformedStart == null || transformedEnd == null) {
          return null;
        }
        return (
          start: transformedStart,
          end: transformedEnd,
        );
      },
      // we only trigger the drag start if the component check passes, but
      // as the user drags the cursor it could end up outside the component
      // bounds; we don't want the event to be lost, so we bypass the check.
      (component, context) => true,
    );
  }
}
