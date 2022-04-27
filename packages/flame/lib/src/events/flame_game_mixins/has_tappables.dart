import 'package:flutter/gestures.dart';
import 'package:meta/meta.dart';

import '../../components/mixins/tappable.dart';
import '../../game/flame_game.dart';
import '../../gestures/events.dart';
import '../multi_tap_listener.dart';

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
}
