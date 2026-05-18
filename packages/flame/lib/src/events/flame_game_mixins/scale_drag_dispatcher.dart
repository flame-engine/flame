import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/src/events/flame_drag_adapter.dart';
import 'package:flame/src/events/flame_game_mixins/dispatcher.dart';
import 'package:flame/src/events/interfaces/scale_listener.dart';
import 'package:flame/src/events/multi_drag_scale_recognizer.dart';
import 'package:flame/src/events/tagged_component.dart';
import 'package:flame/src/game/flame_game.dart';
import 'package:flame/src/game/game_render_box.dart';
import 'package:flutter/gestures.dart';
import 'package:meta/meta.dart';

class MultiDragScaleDispatcherKey implements ComponentKey {
  const MultiDragScaleDispatcherKey();

  @override
  int get hashCode => 91604875; // 'MultiDragScaleDispatcherKey' as hashCode

  @override
  bool operator ==(Object other) =>
      other is MultiDragScaleDispatcherKey && other.hashCode == hashCode;
}

/// Dispatches both drag and scale events to [DragCallbacks] and
/// [ScaleCallbacks] components. Attached to the [FlameGame] automatically
/// when either callback type is first mounted.
///
/// Use [enableDrag] and [enableScale] (called via [addDispatcher]) to control
/// which event types are forwarded to the underlying
/// [MultiDragScaleGestureRecognizer].
class MultiDragScaleDispatcher extends Dispatcher<FlameGame>
    implements MultiDragListener, ScaleListener {
  /// The record of all components currently being touched.
  final Set<TaggedComponent<DragCallbacks>> _records = {};

  int _dragCount = 0;
  int _scaleCount = 0;
  MultiDragScaleGestureRecognizer? _recognizer;

  @visibleForTesting
  bool get hasDrag => _dragCount > 0;

  @visibleForTesting
  bool get hasScale => _scaleCount > 0;

  /// Enables drag forwarding on the underlying recognizer.
  ///
  /// Safe to call before or after [onMount].
  void enableDrag() {
    _dragCount++;
    _recognizer?.hasDrag = true;
  }

  /// Enables scale forwarding on the underlying recognizer.
  ///
  /// Safe to call before or after [onMount].
  void enableScale() {
    _scaleCount++;
    _recognizer?.hasScale = true;
  }

  void _disableDrag() {
    _dragCount--;
    if (_dragCount == 0) {
      _recognizer?.hasDrag = false;
    }
  }

  void _disableScale() {
    _scaleCount--;
    if (_scaleCount == 0) {
      _recognizer?.hasScale = false;
    }
  }

  /// Ensures a [MultiDragScaleDispatcher] is registered on the game that owns
  /// [component], then enables drag and/or scale as requested.
  static void addDispatcher(
    Component component, {
    required bool hasDrag,
    required bool hasScale,
  }) {
    final game = component.findRootGame()!;
    var dispatcher =
        game.findByKey(const MultiDragScaleDispatcherKey())
            as MultiDragScaleDispatcher?;
    if (dispatcher == null) {
      dispatcher = MultiDragScaleDispatcher();
      game.registerKey(const MultiDragScaleDispatcherKey(), dispatcher);
      game.add(dispatcher);
    }
    if (hasDrag) {
      dispatcher.enableDrag();
    }
    if (hasScale) {
      dispatcher.enableScale();
    }
  }

  /// Decrements the reference counts for [component]'s event types and
  /// disables the corresponding recognizer flags when the count reaches zero.
  static void removeDispatcher(
    Component component, {
    required bool hasDrag,
    required bool hasScale,
  }) {
    final game = component.findRootGame();
    if (game == null) {
      return;
    }
    final dispatcher =
        game.findByKey(const MultiDragScaleDispatcherKey())
            as MultiDragScaleDispatcher?;
    if (dispatcher == null) {
      return;
    }
    if (hasDrag) {
      dispatcher._disableDrag();
    }
    if (hasScale) {
      dispatcher._disableScale();
    }
  }

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
    final stale = <TaggedComponent<DragCallbacks>>{};
    event.deliverAtPoint(
      rootComponent: game,
      deliverToAll: true,
      eventHandler: (DragCallbacks component) {
        final record = TaggedComponent(event.pointerId, component);
        if (_records.contains(record)) {
          if (!component.isMounted || component.isRemoving) {
            stale.add(record);
          } else {
            component.onDragUpdate(event);
            updated.add(record);
          }
        }
      },
    );
    for (final record in _records) {
      if (record.pointerId != event.pointerId) {
        continue;
      }
      final component = record.component;
      if (!component.isMounted || component.isRemoving) {
        stale.add(record);
        continue;
      }
      if (!updated.contains(record)) {
        component.onDragUpdate(event);
      }
    }
    if (stale.isNotEmpty) {
      final cancelEvent = DragCancelEvent(event.pointerId);
      for (final record in stale) {
        record.component.onDragCancel(cancelEvent);
      }
      _records.removeAll(stale);
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

  @mustCallSuper
  void onDragCancel(DragCancelEvent event) {
    _records.removeWhere((record) {
      if (record.pointerId == event.pointerId) {
        record.component.onDragCancel(event);
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
  }

  @internal
  @override
  void handleDragUpdate(int pointerId, DragUpdateDetails details) {
    final event = DragUpdateEvent(pointerId, game, details);
    onDragUpdate(event);
  }

  @internal
  @override
  void handleDragEnd(int pointerId, DragEndDetails details) {
    final event = DragEndEvent(pointerId, details);
    onDragEnd(event);
  }

  @internal
  @override
  void handleDragCancel(int pointerId) {
    final event = DragCancelEvent(pointerId);
    onDragCancel(event);
  }

  final Set<TaggedComponent<ScaleCallbacks>> _scaleRecords = {};

  /// Called when the user starts a scale gesture.
  @mustCallSuper
  void onScaleStart(ScaleStartEvent event) {
    event.deliverAtPoint(
      rootComponent: game,
      eventHandler: (ScaleCallbacks component) {
        _scaleRecords.add(TaggedComponent(event.pointerId, component));
        component.onScaleStart(event);
      },
    );
  }

  /// Called continuously as the user updates the scale gesture.
  @mustCallSuper
  void onScaleUpdate(ScaleUpdateEvent event) {
    final updated = <TaggedComponent<ScaleCallbacks>>{};
    final stale = <TaggedComponent<ScaleCallbacks>>{};

    // Deliver to components under the pointer
    event.deliverAtPoint(
      rootComponent: game,
      deliverToAll: true,
      eventHandler: (ScaleCallbacks component) {
        final record = TaggedComponent(event.pointerId, component);
        if (_scaleRecords.contains(record)) {
          if (!component.isMounted || component.isRemoving) {
            stale.add(record);
          } else {
            component.onScaleUpdate(event);
            updated.add(record);
          }
        }
      },
    );

    // Also deliver to components that started the scale but weren't under
    // the pointer this frame
    // Currently, the id passed to the scale
    // events is always 0, so maybe it's not relevant.
    for (final record in _scaleRecords) {
      if (record.pointerId != event.pointerId) {
        continue;
      }
      final component = record.component;
      if (!component.isMounted || component.isRemoving) {
        stale.add(record);
        continue;
      }
      if (!updated.contains(record)) {
        record.component.onScaleUpdate(event);
      }
    }

    if (stale.isNotEmpty) {
      final endEvent = ScaleEndEvent(event.pointerId, ScaleEndDetails());
      for (final record in stale) {
        record.component.onScaleEnd(endEvent);
      }
      _scaleRecords.removeAll(stale);
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
    onScaleUpdate(ScaleUpdateEvent(0, game, details));
  }

  @internal
  @override
  void handleScaleEnd(ScaleEndDetails details) {
    onScaleEnd(ScaleEndEvent(0, details));
  }

  //#endregion

  @override
  void onMount() {
    game.gestureDetectors.register<MultiDragScaleGestureRecognizer>(
      MultiDragScaleGestureRecognizer.new,
      (MultiDragScaleGestureRecognizer instance) {
        _recognizer = instance;
        instance.hasDrag = _dragCount > 0;
        instance.hasScale = _scaleCount > 0;
        instance.onStart = (Offset point) => FlameDragAdapter(this, point);
        instance.onScaleStart = handleScaleStart;
        instance.onScaleUpdate = handleScaleUpdate;
        instance.onScaleEnd = handleScaleEnd;
      },
    );
  }

  @override
  void onRemove() {
    _recognizer = null;
    game.gestureDetectors.unregister<MultiDragScaleGestureRecognizer>();
    game.unregisterKey(const MultiDragScaleDispatcherKey());
  }

  @override
  GameRenderBox get renderBox => game.renderBox;
}
