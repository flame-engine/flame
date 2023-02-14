import 'package:flame/extensions.dart';
import 'package:flame/src/events/messages/drag_end_event.dart';
import 'package:flame/src/events/messages/drag_update_event.dart';
import 'package:flame/src/events/messages/position_event.dart';
import 'package:flame/src/game/flame_game.dart';
import 'package:flame/src/gestures/events.dart';
import 'package:flutter/gestures.dart';

class DragStartEvent extends PositionEvent {
  DragStartEvent(this.pointerId, DragStartDetails details)
      : deviceKind = details.kind ?? PointerDeviceKind.unknown,
        super(
          canvasPosition: details.localPosition.toVector2(),
          devicePosition: details.globalPosition.toVector2(),
        );

  /// The unique identifier of the drag event.
  ///
  /// Subsequent [DragUpdateEvent] or [DragEndEvent] will carry the same pointer
  /// id. This allows distinguishing multiple drags that may occur at the same
  /// time on the same component.
  final int pointerId;

  final PointerDeviceKind deviceKind;

  /// Converts this event into the legacy [DragStartInfo] representation.
  DragStartInfo asInfo(FlameGame game) {
    return DragStartInfo.fromDetails(
      game,
      DragStartDetails(
        globalPosition: devicePosition.toOffset(),
        localPosition: canvasPosition.toOffset(),
        kind: deviceKind,
      ),
    );
  }

  @override
  String toString() => 'DragStartEvent(canvasPosition: $canvasPosition, '
      'devicePosition: $devicePosition, '
      'pointedId: $pointerId, deviceKind: $deviceKind)';
}
