import 'package:flame/components.dart';
import 'package:flame/src/events/messages/event.dart';
import 'package:flame/src/game/game.dart';
import 'package:meta/meta.dart';

class DisplacementContext {
  final Vector2 start;
  final Vector2 end;

  DisplacementContext({
    required this.start,
    required this.end,
  });
}

/// Base class for events that originate at some point on the screen. These
/// include: tap events, drag events, scale events, etc.
///
/// This class includes properties that describe the position where the event
/// has occurred.
abstract class DisplacementEvent extends Event {
  DisplacementEvent(
    this._game, {
    required this.deviceStartPosition,
    required this.deviceEndPosition,
  });
  final Game _game;

  late final Vector2 canvasPosition = canvasStartPosition;
  late final Vector2 devicePosition = deviceStartPosition;
  Vector2 get localPosition => localStartPosition;

  late final Vector2 canvasStartPosition =
      _game.convertGlobalToLocalCoordinate(deviceStartPosition);

  final Vector2 deviceStartPosition;

  Vector2 get localStartPosition => renderingTrace.last.start;

  late final Vector2 canvasEndPosition =
      _game.convertGlobalToLocalCoordinate(deviceEndPosition);

  final Vector2 deviceEndPosition;

  Vector2 get localEndPosition => renderingTrace.last.end;

  final List<DisplacementContext> renderingTrace = [];

  DisplacementContext? get parentContext {
    if (renderingTrace.length >= 2) {
      return renderingTrace[renderingTrace.length - 2];
    } else {
      return null;
    }
  }

  @internal
  void deliverAtPoint<T extends Component>({
    required Component rootComponent,
    required void Function(T component) eventHandler,
    bool deliverToAll = false,
  }) {
    final applicableChildren = rootComponent.componentsAtLocation(
      DisplacementContext(
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
        return DisplacementContext(
          start: transformedStart,
          end: transformedEnd,
        );
      },
      (component, context) => true,
    );
    for (final child in applicableChildren.whereType<T>()) {
      continuePropagation = deliverToAll;
      eventHandler(child);
      if (!continuePropagation) {
        CameraComponent.currentCameras.clear();
        break;
      }
    }
  }
}
