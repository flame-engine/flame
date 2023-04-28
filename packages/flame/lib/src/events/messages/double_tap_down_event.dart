import 'package:flame/extensions.dart';
import 'package:flame/src/events/messages/position_event.dart';
import 'package:flutter/gestures.dart';

class DoubleTapDownEvent extends PositionEvent {
  final PointerDeviceKind deviceKind;

  DoubleTapDownEvent(TapDownDetails details)
      : deviceKind = details.kind ?? PointerDeviceKind.unknown,
        super(
          canvasPosition: details.localPosition.toVector2(),
          devicePosition: details.globalPosition.toVector2(),
        );
}
