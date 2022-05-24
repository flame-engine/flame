import 'package:flame/extensions.dart';
import 'package:flame/src/events/component_mixins/tap_callbacks.dart';
import 'package:flame/src/events/flame_game_mixins/has_tappable_components.dart';
import 'package:flame/src/events/messages/position_event.dart';
import 'package:flame/src/game/mixins/game.dart';
import 'package:flame/src/gestures/events.dart';
import 'package:flutter/gestures.dart';

/// Event propagated through the Flame engine when the user starts a touch on
/// the game canvas.
///
/// In order for a component to be eligible to receive this event, it must add
/// the [TapCallbacks] mixin, and the game object should have the
/// [HasTappableComponents] mixin.
class TapDownEvent extends PositionEvent {
  TapDownEvent(this.pointerId, TapDownDetails details)
      : deviceKind = details.kind,
        super(
          canvasPosition: details.localPosition.toVector2(),
          devicePosition: details.globalPosition.toVector2(),
        );

  final int pointerId;

  final PointerDeviceKind? deviceKind;

  TapDownInfo asInfo(Game game) {
    return TapDownInfo.fromDetails(
      game,
      TapDownDetails(
        globalPosition: devicePosition.toOffset(),
        localPosition: canvasPosition.toOffset(),
        kind: deviceKind,
      ),
    );
  }
}
