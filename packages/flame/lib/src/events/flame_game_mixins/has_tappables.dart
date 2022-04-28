import 'package:flutter/gestures.dart';
import 'package:meta/meta.dart';

import '../../game/flame_game.dart';
import '../../gestures/events.dart';
import '../../components/mixins/tappable.dart';
import '../game_mixins/multi_touch_tap_detector.dart';
import '../interfaces/multi_tap_listener.dart';

/// Mixin that can be added to a [FlameGame] allowing it (and the components
/// attached to the game) to receive tap events.
///
/// This mixin is similar to [MultiTouchTapDetector] on Game, however, it also
/// propagates all tap events down the component tree, allowing each individual
/// component to respond to events that happen on that component.
///
/// This mixin **must be** added to a game if you plan to use any components
/// that are [Tappable].
///
/// See [MultiTapGestureRecognizer] for the description of each individual
/// event.
mixin HasTappables on FlameGame implements MultiTapListener {
  @mustCallSuper
  void onTapCancel(int pointerId) {
    propagateToChildren(
      (Tappable child) => child.handleTapCancel(pointerId),
    );
  }

  @mustCallSuper
  void onTapDown(int pointerId, TapDownInfo info) {
    propagateToChildren(
      (Tappable child) => child.handleTapDown(pointerId, info),
    );
  }

  @mustCallSuper
  void onTapUp(int pointerId, TapUpInfo info) {
    propagateToChildren(
      (Tappable child) => child.handleTapUp(pointerId, info),
    );
  }

  @mustCallSuper
  void onLongTapDown(int pointerId, TapDownInfo info) {
    propagateToChildren(
      (Tappable child) => child.handleLongTapDown(pointerId, info),
    );
  }

  //#region MultiTapListener API
  @override
  double get longTapDelay => 0.300;

  @override
  void handleTap(int pointerId) {}

  @override
  void handleTapCancel(int pointerId) => onTapCancel(pointerId);

  @override
  void handleTapDown(int pointerId, TapDownDetails details) {
    onTapDown(pointerId, TapDownInfo.fromDetails(this, details));
  }

  @override
  void handleTapUp(int pointerId, TapUpDetails details) {
    onTapUp(pointerId, TapUpInfo.fromDetails(this, details));
  }

  @override
  void handleLongTapDown(int pointerId, TapDownDetails details) {
    onLongTapDown(pointerId, TapDownInfo.fromDetails(this, details));
  }
  //#endregion
}
