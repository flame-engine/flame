
import 'package:flame/extensions.dart';
import 'package:flutter/gestures.dart';

class TapDownEvent extends Pointer9Event {
  TapDownEvent(int pointer, TapDownDetails details)
      : canvasPosition = details.localPosition.toVector2(),
        devicePosition = details.globalPosition.toVector2(),
        pointerId = pointer,
        deviceKind = details.kind;

  final Vector2 canvasPosition;

  final Vector2 devicePosition;

  final int pointerId;

  final PointerDeviceKind? deviceKind;
}
