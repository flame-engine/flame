import 'package:flutter/gestures.dart';

import '../../game/mixins/game.dart';
import '../../gestures/events.dart';
import '../multi_tap_listener.dart';

mixin MultiTouchTapDetector on Game implements MultiTapListener {
  void onTap(int pointerId) {}
  void onTapCancel(int pointerId) {}
  void onTapDown(int pointerId, TapDownInfo info) {}
  void onTapUp(int pointerId, TapUpInfo info) {}
  void onLongTapDown(int pointerId, TapDownInfo info) {}

  @override
  double get longTapDelay => 0.300;

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
}
