import 'package:flame/src/components/core/component.dart';
import 'package:flame/src/components/mixins/draggable.dart';
import 'package:flame/src/events/component_mixins/drag_callbacks.dart';
import 'package:flame/src/events/flame_drag_adapter.dart';
import 'package:flame/src/events/flame_game_mixins/has_draggables_bridge.dart';
import 'package:flame/src/events/interfaces/multi_drag_listener.dart';
import 'package:flame/src/events/messages/drag_cancel_event.dart';
import 'package:flame/src/events/messages/drag_end_event.dart';
import 'package:flame/src/events/messages/drag_start_event.dart';
import 'package:flame/src/events/messages/drag_update_event.dart';
import 'package:flame/src/events/tagged_component.dart';
import 'package:flame/src/game/flame_game.dart';
import 'package:flame/src/game/game_render_box.dart';
import 'package:flutter/gestures.dart';
import 'package:meta/meta.dart';

/// **MultiDragDispatcher** facilitates dispatching of drag events to the
/// [DragCallbacks] components in the component tree. It will be attached to
/// the [FlameGame] instance automatically whenever any [DragCallbacks]
/// components are mounted into the component tree.
@internal
class MultiDragDispatcher extends Component implements MultiDragListener {
  /// The record of all components currently being touched.
  final Set<TaggedComponent<DragCallbacks>> _records = {};
  bool _eventHandlerRegistered = false;

  FlameGame get game => parent! as FlameGame;

  /// Called when the user initiates a drag gesture, for example by touching the
  /// screen and then moving the finger.
  ///
  /// The handler propagates the [event] to any component located at the point
  /// of touch and that uses the [DragCallbacks] mixin. The event will be first
  /// delivered to the topmost such component, and then propagated to the
  /// components below only if explicitly requested.
  ///
  /// Each [event] has an `event.pointerId` to keep track of multiple touches
  /// that may occur simultaneously.
  @mustCallSuper
  void onDragStart(DragStartEvent event) {
    event.deliverAtPoint(
      rootComponent: game,
      eventHandler: (DragCallbacks component) {
        _records.add(TaggedComponent(event.pointerId, component));
        component.onDragStart(event);
      },
    );
    // ignore: deprecated_member_use_from_same_package
    if (game is HasDraggablesBridge) {
      final info = event.asInfo(game)..handled = event.handled;
      // ignore: deprecated_member_use_from_same_package
      game.propagateToChildren<Draggable>(
        (c) => c.handleDragStart(event.pointerId, info),
      );
      event.handled = info.handled;
    }
  }

  /// Called continuously during the drag as the user moves their finger.
  ///
  /// The default handler propagates this event to those components who received
  /// the initial [onDragStart] event. If the position of the pointer is outside
  /// of the bounds of the component, then this event will nevertheless be
  /// delivered, however its `event.localPosition` property will contain NaNs.
  @mustCallSuper
  void onDragUpdate(DragUpdateEvent event) {
    final updated = <TaggedComponent<DragCallbacks>>{};
    event.deliverAtPoint(
      rootComponent: game,
      deliverToAll: true,
      eventHandler: (DragCallbacks component) {
        final record = TaggedComponent(event.pointerId, component);
        if (_records.contains(record)) {
          component.onDragUpdate(event);
          updated.add(record);
        }
      },
    );
    for (final record in _records) {
      if (record.pointerId == event.pointerId && !updated.contains(record)) {
        record.component.onDragUpdate(event);
      }
    }
    // ignore: deprecated_member_use_from_same_package
    if (game is HasDraggablesBridge) {
      final info = event.asInfo(game)..handled = event.handled;
      // ignore: deprecated_member_use_from_same_package
      game.propagateToChildren<Draggable>(
        (c) => c.handleDragUpdated(event.pointerId, info),
      );
      event.handled = info.handled;
    }
  }

  /// Called when the drag gesture finishes.
  ///
  /// The default handler will deliver this event to all components who has
  /// previously received the corresponding [onDragStart] event and
  /// [onDragUpdate]s.
  @mustCallSuper
  void onDragEnd(DragEndEvent event) {
    _records.removeWhere((record) {
      if (record.pointerId == event.pointerId) {
        record.component.onDragEnd(event);
        return true;
      }
      return false;
    });
    // ignore: deprecated_member_use_from_same_package
    if (game is HasDraggablesBridge) {
      final info = event.asInfo(game)..handled = event.handled;
      // ignore: deprecated_member_use_from_same_package
      game.propagateToChildren<Draggable>(
        (c) => c.handleDragEnded(event.pointerId, info),
      );
      event.handled = info.handled;
    }
  }

  @mustCallSuper
  void onDragCancel(DragCancelEvent event) {
    _records.removeWhere((record) {
      if (record.pointerId == event.pointerId) {
        record.component.onDragCancel(event);
        return true;
      }
      return false;
    });
    // ignore: deprecated_member_use_from_same_package
    if (game is HasDraggablesBridge) {
      // ignore: deprecated_member_use_from_same_package
      game.propagateToChildren<Draggable>(
        (c) => c.handleDragCanceled(event.pointerId),
      );
    }
  }

  //#region MultiDragListener API

  @internal
  @override
  void handleDragStart(int pointerId, DragStartDetails details) {
    onDragStart(DragStartEvent(pointerId, details));
  }

  @internal
  @override
  void handleDragUpdate(int pointerId, DragUpdateDetails details) {
    onDragUpdate(DragUpdateEvent(pointerId, details));
  }

  @internal
  @override
  void handleDragEnd(int pointerId, DragEndDetails details) {
    onDragEnd(DragEndEvent(pointerId, details));
  }

  @internal
  @override
  void handleDragCancel(int pointerId) {
    onDragCancel(DragCancelEvent(pointerId));
  }

  //#endregion

  @override
  void onMount() {
    if (game.firstChild<MultiDragDispatcher>() == null) {
      game.gestureDetectors.add<ImmediateMultiDragGestureRecognizer>(
        ImmediateMultiDragGestureRecognizer.new,
        (ImmediateMultiDragGestureRecognizer instance) {
          instance.onStart = (Offset point) => FlameDragAdapter(this, point);
        },
      );
      _eventHandlerRegistered = true;
    } else {
      // Ensures that only one MultiDragDispatcher is attached to the Game.
      removeFromParent();
    }
  }

  @override
  void onRemove() {
    if (_eventHandlerRegistered) {
      game.gestureDetectors.remove<ImmediateMultiDragGestureRecognizer>();
      _eventHandlerRegistered = false;
    }
  }

  @override
  GameRenderBox get renderBox => game.renderBox;
}
