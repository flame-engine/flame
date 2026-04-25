import 'package:flame/components.dart';
import 'package:flame/src/events/component_mixins/long_press_callbacks.dart';
import 'package:flame/src/events/flame_game_mixins/dispatcher.dart';
import 'package:flame/src/events/messages/long_press_cancel_event.dart';
import 'package:flame/src/events/messages/long_press_end_event.dart';
import 'package:flame/src/events/messages/long_press_move_update_event.dart';
import 'package:flame/src/events/messages/long_press_start_event.dart';
import 'package:flame/src/events/tagged_component.dart';
import 'package:flame/src/game/flame_game.dart';
import 'package:flutter/gestures.dart';
import 'package:meta/meta.dart';

/// A component that dispatches long-press gesture events to components
/// that use the [LongPressCallbacks] mixin. It will be attached to the
/// [FlameGame] instance automatically whenever any [LongPressCallbacks]
/// components are mounted into the component tree.
class LongPressDispatcher extends Dispatcher<FlameGame> {
  /// Records all components currently being long-pressed, keyed by pointerId.
  final Set<TaggedComponent<LongPressCallbacks>> _records = {};

  /// Monotonically increasing id assigned to each new long press gesture.
  int _nextPointerId = 0;

  /// The pointer id of the current (or most recent) long press gesture.
  int _currentPointerId = 0;

  /// Tracks the previous global position so we can compute frame-to-frame
  /// deltas (Flutter's LongPressMoveUpdateDetails does not provide a delta).
  Offset _previousGlobalPosition = Offset.zero;

  @mustCallSuper
  void onLongPressStart(LongPressStartEvent event) {
    event.deliverAtPoint(
      rootComponent: game,
      eventHandler: (LongPressCallbacks component) {
        _records.add(TaggedComponent(event.pointerId, component));
        component.onLongPressStart(event);
      },
    );
  }

  @mustCallSuper
  void onLongPressMoveUpdate(LongPressMoveUpdateEvent event) {
    final delivered = <TaggedComponent<LongPressCallbacks>>{};
    event.deliverAtPoint(
      rootComponent: game,
      deliverToAll: true,
      eventHandler: (LongPressCallbacks component) {
        final record = TaggedComponent(event.pointerId, component);
        if (_records.contains(record)) {
          component.onLongPressMoveUpdate(event);
          delivered.add(record);
        }
      },
    );
    for (final record in _records) {
      if (record.pointerId == event.pointerId && !delivered.contains(record)) {
        record.component.onLongPressMoveUpdate(event);
      }
    }
  }

  @mustCallSuper
  void onLongPressEnd(LongPressEndEvent event) {
    _records.removeWhere((record) {
      if (record.pointerId == event.pointerId) {
        record.component.onLongPressEnd(event);
        return true;
      }
      return false;
    });
  }

  @mustCallSuper
  void onLongPressCancel(LongPressCancelEvent event) {
    _records.removeWhere((record) {
      if (record.pointerId == event.pointerId) {
        record.component.onLongPressCancel(event);
        return true;
      }
      return false;
    });
  }

  //#region Gesture recognizer handlers

  @internal
  void handleLongPressStart(LongPressStartDetails details) {
    _currentPointerId = _nextPointerId++;
    _previousGlobalPosition = details.globalPosition;
    onLongPressStart(
      LongPressStartEvent(_currentPointerId, game, details),
    );
  }

  @internal
  void handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    onLongPressMoveUpdate(
      LongPressMoveUpdateEvent(
        _currentPointerId,
        game,
        details,
        previousGlobalPosition: _previousGlobalPosition,
      ),
    );
    _previousGlobalPosition = details.globalPosition;
  }

  @internal
  void handleLongPressEnd(LongPressEndDetails details) {
    onLongPressEnd(
      LongPressEndEvent(_currentPointerId, game, details),
    );
  }

  @internal
  void handleLongPressCancel() {
    onLongPressCancel(
      LongPressCancelEvent(_currentPointerId),
    );
  }

  //#endregion

  static void addDispatcher(Component component) {
    Dispatcher.addDispatcher(
      component,
      const LongPressDispatcherKey(),
      LongPressDispatcher.new,
    );
  }

  @override
  void onMount() {
    game.gestureDetectors.register<LongPressGestureRecognizer>(
      LongPressGestureRecognizer.new,
      (LongPressGestureRecognizer instance) {
        instance
          ..onLongPressStart = handleLongPressStart
          ..onLongPressMoveUpdate = handleLongPressMoveUpdate
          ..onLongPressEnd = handleLongPressEnd
          ..onLongPressCancel = handleLongPressCancel;
      },
    );
    super.onMount();
  }

  @override
  void onRemove() {
    Dispatcher.removeDispatcher(
      game,
      const LongPressDispatcherKey(),
      unregister: () {
        game.gestureDetectors.unregister<LongPressGestureRecognizer>();
      },
    );
    super.onRemove();
  }
}

/// Unique key for the [LongPressDispatcher] so the game can identify it.
class LongPressDispatcherKey implements ComponentKey {
  const LongPressDispatcherKey();

  @override
  int get hashCode => 71825634; // arbitrary unique number

  @override
  bool operator ==(Object other) =>
      other is LongPressDispatcherKey && other.hashCode == hashCode;
}
