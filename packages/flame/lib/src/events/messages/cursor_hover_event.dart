import 'package:flame/image_composition.dart';
import 'package:flame/src/events/messages/position_event.dart';
import 'package:flame/src/game/game.dart';
import 'package:flame/src/gestures/events.dart';

import 'package:flutter/gestures.dart';

class CursorHoverEvent extends PositionEvent {
  CursorHoverEvent(this.pointerId, PointerHoverEvent pointerHoverEvent)
      : deviceKind = pointerHoverEvent.kind,
        super(
          canvasPosition: pointerHoverEvent.localPosition.toVector2(),
          devicePosition: pointerHoverEvent.position.toVector2(),
        );

  final int pointerId;

  final PointerDeviceKind deviceKind;

  PointerHoverInfo asInfo(Game game) {
    return PointerHoverInfo.fromDetails(
      game,
      PointerHoverEvent(
        position: devicePosition.toOffset(),
        kind: deviceKind,
      ),
    );
  }

  @override
  String toString() => 'CursorHoverEvent(canvasPosition: $canvasPosition, '
      'devicePosition: $devicePosition, '
      'pointerId: $pointerId, deviceKind: $deviceKind)';
}
