import 'package:flame/src/components/mixins/draggable.dart';
import 'package:flame/src/events/component_mixins/drag_callbacks.dart';
import 'package:flame/src/events/flame_game_mixins/has_draggables_bridge.dart';
import 'package:flame/src/events/flame_game_mixins/has_tappable_components.dart';
import 'package:flame/src/events/game_mixins/multi_touch_drag_detector.dart';
import 'package:flame/src/events/interfaces/multi_drag_listener.dart';
import 'package:flame/src/events/messages/drag_cancel_event.dart';
import 'package:flame/src/events/messages/drag_end_event.dart';
import 'package:flame/src/events/messages/drag_start_event.dart';
import 'package:flame/src/events/messages/drag_update_event.dart';
import 'package:flame/src/events/tagged_component.dart';
import 'package:flame/src/game/flame_game.dart';
import 'package:flutter/gestures.dart';
import 'package:meta/meta.dart';

/// This mixin allows a [FlameGame] to respond to drag events, and also delivers
/// those events to components that have the [DragCallbacks] mixin.
///
/// The following events are supported by the mixin: [onDragStart],
/// [onDragUpdate], [onDragEnd], and [onDragCancel] -- see their individual
/// descriptions for more details.
///
/// Each event handler can be overridden. One scenario when this could be useful
/// is to check the `event.handled` property after the event has been sent down
/// the component tree.
///
/// === Usage notes ===
/// - If your game uses components with [DragCallbacks], then this mixin must be
///   added to the [FlameGame] in order for [DragCallbacks] to work properly.
/// - If your game also uses [Draggable] components, then add the
///   [HasDraggablesBridge] mixin as well (instead of `HasDraggables`).
/// - If your game has no draggable components, then do not use this mixin.
///   Instead, consider using [MultiTouchDragDetector].
mixin HasDraggableComponents on FlameGame implements MultiDragListener {
  /// The record of all components currently being touched.
  final Set<TaggedComponent<DragCallbacks>> _records = {};

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
  ///
  /// If [HasDraggableComponents] is the only pointer events mixin in use, then
  /// [onDragStart] will be called immediately when the user touches the screen.
  /// If, however, the game uses other pointer events mixins as well, such as
  /// [HasTappableComponents], then this even will only occur after the gesture
  /// can be unambiguously interpreted as a drag, i.e. only after the user has
  /// both touched the screen and moved their finger for some minimum distance.
  @mustCallSuper
  void onDragStart(DragStartEvent event) {
    event.deliverAtPoint(
      rootComponent: this,
      eventHandler: (DragCallbacks component) {
        _records.add(TaggedComponent(event.pointerId, component));
        component.onDragStart(event);
      },
    );
    if (this is HasDraggablesBridge) {
      final info = event.asInfo(this)..handled = event.handled;
      propagateToChildren<Draggable>(
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
      rootComponent: this,
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
    if (this is HasDraggablesBridge) {
      final info = event.asInfo(this)..handled = event.handled;
      propagateToChildren<Draggable>(
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
    if (this is HasDraggablesBridge) {
      final info = event.asInfo(this)..handled = event.handled;
      propagateToChildren<Draggable>(
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
    if (this is HasDraggablesBridge) {
      propagateToChildren<Draggable>(
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
}
