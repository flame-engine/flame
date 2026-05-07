import 'package:flame/components.dart';
import 'package:flame/src/events/flame_game_mixins/long_press_dispatcher.dart';
import 'package:flame/src/events/messages/long_press_cancel_event.dart';
import 'package:flame/src/events/messages/long_press_end_event.dart';
import 'package:flame/src/events/messages/long_press_move_update_event.dart';
import 'package:flame/src/events/messages/long_press_start_event.dart';
import 'package:flutter/foundation.dart';

/// This mixin can be added to a [Component] allowing it to receive
/// long-press events.
///
/// In addition to adding this mixin, the component must also implement the
/// [containsLocalPoint] method — only events that occur on top of the
/// component will be delivered.
///
/// The following callbacks are available:
/// - [onLongPressStart]: called when the long press gesture is recognized.
/// - [onLongPressMoveUpdate]: called when the pointer moves during an active
///   long press.
/// - [onLongPressEnd]: called when the pointer is lifted after a long press.
/// - [onLongPressCancel]: called if the gesture is cancelled before completion.
///
/// This callback uses [LongPressDispatcher] to route events.
mixin LongPressCallbacks on Component {
  bool _isLongPressing = false;

  /// Returns true while a long press gesture is active on this component.
  bool get isLongPressing => _isLongPressing;

  @mustCallSuper
  void onLongPressStart(LongPressStartEvent event) {
    _isLongPressing = true;
  }

  void onLongPressMoveUpdate(LongPressMoveUpdateEvent event) {}

  @mustCallSuper
  void onLongPressEnd(LongPressEndEvent event) {
    _isLongPressing = false;
  }

  @mustCallSuper
  void onLongPressCancel(LongPressCancelEvent event) {
    _isLongPressing = false;
  }

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    LongPressDispatcher.addDispatcher(this);
  }
}
