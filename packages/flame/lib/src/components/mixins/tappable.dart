import 'package:flame/components.dart';
import 'package:flame/src/events/flame_game_mixins/has_tappable_components.dart';
import 'package:flame/src/game/mixins/has_tappables.dart';
import 'package:flame/src/gestures/events.dart';
import 'package:flutter/gestures.dart';
import 'package:meta/meta.dart';

/// Mixin that can be added to any [Component] allowing it to receive tap
/// events.
///
/// When using this mixin, also add [HasTappables] to your game, which handles
/// propagation of tap events from the root game to individual components.
///
/// See [MultiTapGestureRecognizer] for the description of each individual
/// event.
mixin Tappable on Component {
  // bool onTap() => true;
  bool onTapDown(TapDownInfo info) => true;
  bool onLongTapDown(TapDownInfo info) => true;
  bool onTapUp(TapUpInfo info) => true;
  bool onTapCancel() => true;

  int? _currentPointerId;

  bool _checkPointerId(int pointerId) => _currentPointerId == pointerId;

  bool handleTapDown(int pointerId, TapDownInfo info) {
    if (containsPoint(eventPosition(info))) {
      _currentPointerId = pointerId;
      return onTapDown(info);
    }
    return true;
  }

  bool handleTapUp(int pointerId, TapUpInfo info) {
    if (_checkPointerId(pointerId) && containsPoint(eventPosition(info))) {
      _currentPointerId = null;
      return onTapUp(info);
    }
    return true;
  }

  bool handleTapCancel(int pointerId) {
    if (_checkPointerId(pointerId)) {
      _currentPointerId = null;
      return onTapCancel();
    }
    return true;
  }

  bool handleLongTapDown(int pointerId, TapDownInfo info) {
    if (_checkPointerId(pointerId) && containsPoint(eventPosition(info))) {
      return onLongTapDown(info);
    }
    return true;
  }

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    final game = findGame()!;
    assert(
      game is HasTappables || game is HasTappablesBridge,
      'Tappable components can only be added to a FlameGame with HasTappables',
    );
  }
}
