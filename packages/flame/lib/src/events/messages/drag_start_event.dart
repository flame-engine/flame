import 'package:flame/extensions.dart';
import 'package:flame/src/events/messages/position_event.dart';
import 'package:flame/src/game/flame_game.dart';
import 'package:flame/src/gestures/events.dart';
import 'package:flutter/gestures.dart';

class DragStartEvent extends PositionEvent {
  DragStartEvent(this.pointerId, DragStartDetails details)
      : timestamp = details.sourceTimeStamp ?? Duration.zero,
        deviceKind = details.kind ?? PointerDeviceKind.unknown,
        super(
          canvasPosition: details.localPosition.toVector2(),
          devicePosition: details.globalPosition.toVector2(),
        );

  final Duration timestamp;
  final int pointerId;
  final PointerDeviceKind deviceKind;

  /// Converts this event into the legacy [DragStartInfo] representation.
  DragStartInfo asInfo(FlameGame game) {
    return DragStartInfo.fromDetails(game,
      DragStartDetails(
        sourceTimeStamp: timestamp,
        globalPosition: devicePosition.toOffset(),
        localPosition: canvasPosition.toOffset(),
        kind: deviceKind,
      ),
    );
  }
}
