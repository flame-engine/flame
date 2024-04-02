import 'package:flame/events.dart';
import 'package:flame/src/events/tap_config.dart';
import 'package:flame/src/game/game.dart';
import 'package:flutter/gestures.dart';

/// Mixin that can be added to a [Game] allowing it to receive tap events.
///
/// The user can override one of the callback methods
///  - [onTapDown]
///  - [onLongTapDown]
///  - [onTapUp]
///  - [onTapCancel]
///  - [onTap]
/// in order to respond to each corresponding event. Those events whose methods
/// are not overridden are ignored. See [MultiTapListener] for the description
/// of each individual event.
mixin MultiTouchTapDetector on Game implements MultiTapListener {
  void onTapDown(int pointerId, TapDownInfo info) {}
  void onLongTapDown(int pointerId, TapDownInfo info) {}
  void onTapUp(int pointerId, TapUpInfo info) {}
  void onTapCancel(int pointerId) {}
  void onTap(int pointerId) {}

  //#region MultiTapListener API
  @override
  double get longTapDelay => TapConfig.longTapDelay;

  @override
  void handleTap(int pointerId) => onTap(pointerId);

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

  @override
  void mount() {
    gestureDetectors.add<MultiTapGestureRecognizer>(
      MultiTapGestureRecognizer.new,
      (MultiTapGestureRecognizer instance) {},
    );
    super.mount();
  }
}
