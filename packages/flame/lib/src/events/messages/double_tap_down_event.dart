import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/gestures.dart';

class DoubleTapDownEvent(super.game, TapDownDetails details)
    extends PositionEvent<TapDownDetails> {
  final PointerDeviceKind deviceKind =
      details.kind ?? PointerDeviceKind.unknown;

  this
    : super(
        raw: details,
        devicePosition: details.globalPosition.toVector2(),
      );
}
