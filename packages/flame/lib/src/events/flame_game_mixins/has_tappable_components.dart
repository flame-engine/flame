import 'package:flame/src/events/component_mixins/tap_callbacks.dart';
import 'package:flame/src/events/interfaces/multi_tap_listener.dart';
import 'package:flame/src/events/messages/tap_down_event.dart';
import 'package:flame/src/game/flame_game.dart';
import 'package:flutter/gestures.dart';

mixin HasTappableComponents on FlameGame implements MultiTapListener {
  //#region MultiTapListener API
  @override
  double get longTapDelay => 0.300;

  @override
  void handleTap(int pointerId) {}

  // @override
  // void handleTapCancel(int pointerId) => onTapCancel(pointerId);
  //
  @override
  void handleTapDown(int pointerId, TapDownDetails details) {
    final event = TapDownEvent(pointerId, details);
    event.deliverAtPoint(
      rootComponent: this,
      eventHandler: (TapCallbacks component) => component.onTapDown(event),
    );
  }
  //
  // @override
  // void handleTapUp(int pointerId, TapUpDetails details) {
  //   onTapUp(pointerId, TapUpInfo.fromDetails(this, details));
  // }
  //
  // @override
  // void handleLongTapDown(int pointerId, TapDownDetails details) {
  //   onLongTapDown(pointerId, TapDownInfo.fromDetails(this, details));
  // }
  //#endregion
}
