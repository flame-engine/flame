import 'package:flame/extensions.dart';
import 'package:flame/src/events/messages/position_event.dart';
import 'package:flutter/gestures.dart';

/// Event propagated through the Flame engine when the user starts a touch on
/// the game canvas.
class TapDownEvent extends PositionEvent {
  TapDownEvent(this.pointerId, TapDownDetails details)
      : deviceKind = details.kind,
        super(
          canvasPosition: details.localPosition.toVector2(),
          devicePosition: details.globalPosition.toVector2(),
        );

  final int pointerId;

  final PointerDeviceKind? deviceKind;
}
