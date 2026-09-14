import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/src/events/tagged_component.dart';
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
class MultiDragScaleDispatcher extends Dispatcher<FlameGame> {
  /// The record of all components currently being touched.
  final Set<TaggedComponent<DragCallbacks>> _records = {};

  // Reference counts rather than booleans so that enableDrag/enableScale can
  // be called before onMount (when _recognizer is null). onMount uses these
  // counts to initialize the recognizer flags.
  int _dragCount = 0;
  int _scaleCount = 0;
  MultiDragScaleGestureRecognizer? _recognizer;

  /// The minimum scale factor change required before a scale gesture is
  /// recognized. Must be greater than 1.0. The default value is 1.05, meaning
  /// the fingers must spread or pinch by at least 5% before scale events start
  /// firing. Set this before the first [ScaleCallbacks] component mounts.
  double scaleThreshold = 1.05;

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
    assert(_dragCount > 0, '_disableDrag called more times than enableDrag');
    _dragCount--;
    if (_dragCount == 0) {
      _recognizer?.hasDrag = false;
    }
  }

  void _disableScale() {
    assert(_scaleCount > 0, '_disableScale called more times than enableScale');
    _scaleCount--;
    if (_scaleCount == 0) {
      _recognizer?.hasScale = false;
    }
  }

  /// Ensures a [MultiDragScaleDispatcher] is registered on the game that owns
  /// [component], then enables drag and/or scale as requested.
  ///
  /// For a component that mixes both [DragCallbacks] and [ScaleCallbacks],
  /// this method is called twice from their separate [onMount] chains, once
  /// with [hasDrag]=true and once with [hasScale]=true. The second call finds
  /// the existing dispatcher and simply enables the remaining flag.
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
  ///
  /// A component that sets [DragCallbacks.allowsMultiPointerDrag] to false is
  /// skipped while it already has a drag in progress, and the event carries on
  /// to the components below it.
  @mustCallSuper
  void onDragStart(DragStartEvent event) {
    event.deliverAtPoint(
      rootComponent: gameRef,
      eventHandler: (DragCallbacks component) {
        if (!component.allowsMultiPointerDrag && _isDragging(component)) {
          event.continuePropagation = true;
          return;
        }
        _records.add(TaggedComponent(event.pointerId, component));
        component.onDragStart(event);
      },
    );
  }

  bool _isDragging(DragCallbacks component) {
    return _records.any((record) => record.component == component);
  }

  /// Called continuously during the drag as the user moves their finger.
  ///
  /// The default handler propagates this event to those components who received
  /// the initial [onDragStart] event. If the position of the pointer is outside
  /// of the bounds of the component, then this event will nevertheless be
  /// delivered, with local coordinates that fall outside those bounds. A
  /// component that hit testing no longer reaches at all -- because an ancestor
  /// started ignoring events, say -- is delivered to from [_records] instead,
  /// with an empty rendering trace, so its local coordinates are unavailable.
  @mustCallSuper
  void onDragUpdate(DragUpdateEvent event) {
    final updated = <TaggedComponent<DragCallbacks>>{};
    final stale = <TaggedComponent<DragCallbacks>>{};
    event.deliverAtPoint(
      rootComponent: gameRef,
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

  //#region MultiDragScaleGestureRecognizer drag API

  /// The beginning of a drag operation.
  ///
  /// This does not fire as soon as the pointer touches the screen: the
  /// recognizer waits until the movement exceeds the platform's touch slop, so
  /// that a tap with a slightly wobbling finger stays a tap. The movement
  /// accumulated up to that point is delivered in the first
  /// [handleDragUpdate].
  @internal
  void handleDragStart(int pointerId, DragStartDetails details) {
    final event = DragStartEvent(pointerId, gameRef, details);
    onDragStart(event);
  }

  /// The pointer that was touching the screen has moved.
  ///
  /// This occurs frequently during the drag, and only when the point of touch
  /// actually moves, not when it stays still.
  @internal
  void handleDragUpdate(int pointerId, DragUpdateDetails details) {
    final event = DragUpdateEvent(pointerId, gameRef, details);
    onDragUpdate(event);
  }

  /// Marks the end of a drag operation.
  ///
  /// Fires when the pointer stops touching the screen, even if the pointer is
  /// outside of the game widget at the time.
  @internal
  void handleDragEnd(int pointerId, DragEndDetails details) {
    final event = DragEndEvent(pointerId, details);
    onDragEnd(event);
  }

  /// The drag operation is cancelled.
  ///
  /// For example, this may happen if the drag was interrupted by a
  /// system-modal dialog appearing during the drag.
  @internal
  void handleDragCancel(int pointerId) {
    final event = DragCancelEvent(pointerId);
    onDragCancel(event);
  }

  //#endregion

  final Set<TaggedComponent<ScaleCallbacks>> _scaleRecords = {};

  /// Called when the user starts a scale gesture.
  @mustCallSuper
  void onScaleStart(ScaleStartEvent event) {
    event.deliverAtPoint(
      rootComponent: gameRef,
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
      rootComponent: gameRef,
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

  //#region MultiDragScaleGestureRecognizer scale API

  /// The beginning of a scale operation.
  ///
  /// Fires once two or more pointers are touching the screen and their
  /// movement exceeds the recognizer's [scaleThreshold].
  @internal
  void handleScaleStart(ScaleStartDetails details) {
    onScaleStart(ScaleStartEvent(0, gameRef, details));
  }

  /// The pointers taking part in the scale gesture have moved.
  ///
  /// This occurs frequently during the gesture, reporting the current scale
  /// factors, the rotation and the focal point.
  @internal
  void handleScaleUpdate(ScaleUpdateDetails details) {
    onScaleUpdate(ScaleUpdateEvent(0, gameRef, details));
  }

  /// Marks the end of a scale operation.
  ///
  /// Fires once fewer than two pointers are left touching the screen.
  @internal
  void handleScaleEnd(ScaleEndDetails details) {
    onScaleEnd(ScaleEndEvent(0, details));
  }

  //#endregion

  @override
  void onMount() {
    gameRef.gestureDetectors.register<MultiDragScaleGestureRecognizer>(
      () => MultiDragScaleGestureRecognizer(scaleThreshold: scaleThreshold),
      (MultiDragScaleGestureRecognizer instance) {
        _recognizer = instance;
        instance.hasDrag = _dragCount > 0;
        instance.hasScale = _scaleCount > 0;
        instance.onStart = (Offset point) => _FlameDragAdapter(this, point);
        instance.onScaleStart = handleScaleStart;
        instance.onScaleUpdate = handleScaleUpdate;
        instance.onScaleEnd = handleScaleEnd;
      },
    );
  }

  @override
  void onRemove() {
    _recognizer = null;
    gameRef.gestureDetectors.unregister<MultiDragScaleGestureRecognizer>();
    gameRef.unregisterKey(const MultiDragScaleDispatcherKey());
  }

  GameRenderBox get _renderBox => gameRef.renderBox;
}

/// Adapts the drag API expected by [MultiDragScaleGestureRecognizer] into the
/// one expected by [MultiDragScaleDispatcher].
///
/// Flutter identifies a drag by the [Drag] object returned from `onStart`, and
/// its `update`/`end`/`cancel` callbacks carry no pointer id of their own. The
/// dispatcher, in contrast, is shared by the whole game and needs to tell
/// pointers apart, so one of these is created per pointer to hold the id and
/// attach it to every event that follows.
class _FlameDragAdapter implements Drag {
  _FlameDragAdapter(this._dispatcher, Offset startPoint) {
    _id = _globalIdCounter++;
    _dispatcher.handleDragStart(
      _id,
      DragStartDetails(
        sourceTimeStamp: Duration.zero,
        globalPosition: startPoint,
        localPosition: _dispatcher._renderBox.globalToLocal(startPoint),
      ),
    );
  }

  final MultiDragScaleDispatcher _dispatcher;
  late final int _id;
  static int _globalIdCounter = 0;

  @override
  void update(DragUpdateDetails event) =>
      _dispatcher.handleDragUpdate(_id, event);

  @override
  void end(DragEndDetails event) => _dispatcher.handleDragEnd(_id, event);

  @override
  void cancel() => _dispatcher.handleDragCancel(_id);
}
