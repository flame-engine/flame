import 'package:flame/extensions.dart';
import 'package:flame/src/events/messages/position_event.dart';
import 'package:flame/src/game/mixins/game.dart';
import 'package:flame/src/gestures/events.dart';
import 'package:flutter/gestures.dart';

class TapUpEvent extends PositionEvent {
  TapUpEvent(this.pointerId, TapUpDetails details)
      : deviceKind = details.kind,
        super(
          canvasPosition: details.localPosition.toVector2(),
          devicePosition: details.globalPosition.toVector2(),
        );

  final int pointerId;

  final PointerDeviceKind deviceKind;


  TapUpInfo asInfo(Game game) {
    return TapUpInfo.fromDetails(
      game,
      TapUpDetails(
        globalPosition: devicePosition.toOffset(),
        localPosition: canvasPosition.toOffset(),
        kind: deviceKind,
      ),
    );
  }
}
