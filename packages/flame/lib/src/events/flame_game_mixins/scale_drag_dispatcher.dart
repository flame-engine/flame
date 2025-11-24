import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/src/events/flame_drag_adapter.dart';
import 'package:flame/src/events/interfaces/scale_listener.dart';
import 'package:flame/src/events/multi_drag_scale_recognizer.dart';
import 'package:flame/src/events/tagged_component.dart';
import 'package:flame/src/game/flame_game.dart';
import 'package:flame/src/game/game_render_box.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class MultiDragScaleDispatcherKey implements ComponentKey {
  const MultiDragScaleDispatcherKey();

  @override
  int get hashCode => 91604875; // 'MultiDragDispatcherKey' as hashCode

  @override
  bool operator ==(Object other) =>
      other is MultiDragScaleDispatcherKey && other.hashCode == hashCode;
}

/// **MultiDragDispatcher** facilitates dispatching of drag events to the
/// [DragCallbacks] components in the component tree. It will be attached to
/// the [FlameGame] instance automatically whenever any [DragCallbacks]
/// components are mounted into the component tree.
class MultiDragScaleDispatcher extends Component
    implements MultiDragListener, ScaleListener {
  /// The record of all components currently being touched.
  final Set<TaggedComponent<ScaleDragCallbacks>> _records = {};

  final _dragUpdateController = StreamController<DragUpdateEvent>.broadcast(
    sync: true,
  );

  Stream<DragUpdateEvent> get onUpdate => _dragUpdateController.stream;

  final _dragStartController = StreamController<DragStartEvent>.broadcast(
    sync: true,
  );

  Stream<DragStartEvent> get onStart => _dragStartController.stream;

  final _dragEndController = StreamController<DragEndEvent>.broadcast(
    sync: true,
  );

  Stream<DragEndEvent> get onEnd => _dragEndController.stream;

  final _dragCancelController = StreamController<DragCancelEvent>.broadcast(
    sync: true,
  );

  Stream<DragCancelEvent> get onCancel => _dragCancelController.stream;

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
    debugPrint("dispatcher on drag start");
    event.deliverAtPoint(
      rootComponent: game,
      eventHandler: (ScaleDragCallbacks component) {
        _records.add(TaggedComponent(event.pointerId, component));
        component.onDragStart(event);
      },
    );
  }

  /// Called continuously during the drag as the user moves their finger.
  ///
  /// The default handler propagates this event to those components who received
  /// the initial [onDragStart] event. If the position of the pointer is outside
  /// of the bounds of the component, then this event will nevertheless be
  /// delivered, however its `event.localPosition` property will contain NaNs.
  @mustCallSuper
  void onDragUpdate(DragUpdateEvent event) {
    final updated = <TaggedComponent<ScaleDragCallbacks>>{};
    event.deliverAtPoint(
      rootComponent: game,
      deliverToAll: true,
      eventHandler: (ScaleDragCallbacks component) {
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
  }

  //#region MultiDragListener API

  @internal
  @override
  void handleDragStart(int pointerId, DragStartDetails details) {
    final event = DragStartEvent(pointerId, game, details);
    onDragStart(event);
    _dragStartController.add(event);
  }

  @internal
  @override
  void handleDragUpdate(int pointerId, DragUpdateDetails details) {
    final event = DragUpdateEvent(pointerId, game, details);
    onDragUpdate(event);
    _dragUpdateController.add(event);
  }

  @internal
  @override
  void handleDragEnd(int pointerId, DragEndDetails details) {
    final event = DragEndEvent(pointerId, details);
    onDragEnd(event);
    _dragEndController.add(event);
  }

  final Set<TaggedComponent<ScaleDragCallbacks>> _scaleRecords = {};

  /// Called when the user starts a scale gesture.
  @mustCallSuper
  void onScaleStart(ScaleStartEvent event) {
    event.deliverAtPoint(
      rootComponent: game,
      eventHandler: (ScaleDragCallbacks component) {
        _scaleRecords.add(TaggedComponent(event.pointerId, component));
        component.onScaleStart(event);
      },
    );
  }

  /// Called continuously as the user updates the scale gesture.
  @mustCallSuper
  void onScaleUpdate(ScaleUpdateEvent event) {
    final updated = <TaggedComponent<ScaleDragCallbacks>>{};

    // Deliver to components under the pointer
    event.deliverAtPoint(
      rootComponent: game,
      deliverToAll: true,
      eventHandler: (ScaleDragCallbacks component) {
        final record = TaggedComponent(event.pointerId, component);
        if (_scaleRecords.contains(record)) {
          component.onScaleUpdate(event);
          updated.add(record);
        }
      },
    );

    // Also deliver to components that started the scale but weren't under
    // the pointer this frame
    // Currently, the id passed to the scale
    // events is always 0, so maybe it's not relevant.
    for (final record in _scaleRecords) {
      if (record.pointerId == event.pointerId && !updated.contains(record)) {
        record.component.onScaleUpdate(event);
      }
    }
  }

  /// Called when the scale gesture ends.
  @mustCallSuper
  void onScaleEnd(ScaleEndEvent event) {
    _scaleRecords.removeWhere((record) {
      if (record.pointerId == event.pointerId) {
        record.component.onScaleEnd(event);
        return true;
      }
      return false;
    });
  }

  //#region ScaleListener API

  @internal
  @override
  void handleScaleStart(ScaleStartDetails details) {
    onScaleStart(ScaleStartEvent(0, game, details));
  }

  @internal
  @override
  void handleScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount != 1) {
      onScaleUpdate(ScaleUpdateEvent(0, game, details));
      return;
    }

    /*final newDetails = _buildNewUpdateDetails(details);
    if (newDetails != null) {
      onScaleUpdate(ScaleUpdateEvent(0, game, newDetails));
    }*/
  }

  @internal
  @override
  void handleScaleEnd(ScaleEndDetails details) {
    onScaleEnd(ScaleEndEvent(0, details));
  }

  //#endregion

  @override
  void onMount() {
    game.gestureDetectors.add<MultiDragScaleGestureRecognizer>(
      MultiDragScaleGestureRecognizer.new,
      (MultiDragScaleGestureRecognizer instance) {
        instance.onStart = (Offset point) => FlameDragAdapter(this, point);
        instance.onScaleStart = handleScaleStart;
        instance.onScaleUpdate = handleScaleUpdate;
        instance.onScaleEnd = handleScaleEnd;
      },
    );
  }

  @override
  void onRemove() {
    game.gestureDetectors.remove<MultiDragScaleGestureRecognizer>();
    game.unregisterKey(const MultiDragScaleDispatcherKey());
    _dragUpdateController.close();
    _dragCancelController.close();
    _dragStartController.close();
    _dragEndController.close();
  }

  @override
  GameRenderBox get renderBox => game.renderBox;

  @override
  void handleDragCancel(int pointerId) {
    // TODO: implement handleDragCancel
  }
}
