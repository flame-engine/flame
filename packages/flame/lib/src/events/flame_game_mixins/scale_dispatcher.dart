import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/src/events/interfaces/scale_listener.dart';
import 'package:flame/src/events/tagged_component.dart';
import 'package:flutter/gestures.dart';
import 'package:meta/meta.dart';

/// Unique key for the [ScaleDispatcher] so the game can identify it.
class ScaleDispatcherKey implements ComponentKey {
  const ScaleDispatcherKey();

  @override
  int get hashCode => 31650892; // arbitrary unique number

  @override
  bool operator ==(Object other) =>
      other is ScaleDispatcherKey && other.hashCode == hashCode;
}

/// A component that dispatches scale (pinch/zoom) events to components
/// implementing [ScaleCallbacks]. It will be attached to
/// the [FlameGame] instance automatically whenever any [ScaleCallbacks]
/// components are mounted into the component tree.
class ScaleDispatcher extends Component implements ScaleListener {
  /// Records all components currently being scaled, keyed by pointerId.
  final Set<TaggedComponent<ScaleCallbacks>> _records = {};

  FlameGame get game => parent! as FlameGame;

  bool _shouldBeRemoved = false;

  /// Called when the user starts a scale gesture.
  @mustCallSuper
  void onScaleStart(ScaleStartEvent event) {
    event.deliverAtPoint(
      rootComponent: game,
      eventHandler: (ScaleCallbacks component) {
        _records.add(TaggedComponent(event.pointerId, component));
        component.onScaleStart(event);
      },
    );
  }

  /// Called continuously as the user updates the scale gesture.
  @mustCallSuper
  void onScaleUpdate(ScaleUpdateEvent event) {
    final updated = <TaggedComponent<ScaleCallbacks>>{};

    // Deliver to components under the pointer
    event.deliverAtPoint(
      rootComponent: game,
      deliverToAll: true,
      eventHandler: (ScaleCallbacks component) {
        final record = TaggedComponent(event.pointerId, component);
        if (_records.contains(record)) {
          component.onScaleUpdate(event);
          updated.add(record);
        }
      },
    );

    // Also deliver to components that started the scale but weren't under
    // the pointer this frame
    // Currently, the id passed to the scale
    // events is always 0, so maybe it's not relevant.
    for (final record in _records) {
      if (record.pointerId == event.pointerId && !updated.contains(record)) {
        record.component.onScaleUpdate(event);
      }
    }
  }

  /// Called when the scale gesture ends.
  @mustCallSuper
  void onScaleEnd(ScaleEndEvent event) {
    _records.removeWhere((record) {
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
    _tryRemoving();
  }

  //#endregion

  void markForRemoval() {
    _shouldBeRemoved = true;
    _tryRemoving();
  }

  bool _tryRemoving() {
    // there's no more fingers
    // that started dragging before _shouldBeRemoved flag was set to true.
    if (_records.isEmpty && _shouldBeRemoved && isMounted) {
      removeFromParent();
      return true;
    }
    return false;
  }

  @override
  void onMount() {
    if (_tryRemoving()) {
      return;
    }
    game.gestureDetectors.add<ScaleGestureRecognizer>(
      ScaleGestureRecognizer.new,
      (ScaleGestureRecognizer instance) {
        instance
          ..onStart = handleScaleStart
          ..onUpdate = handleScaleUpdate
          ..onEnd = handleScaleEnd;
      },
    );
    super.onMount();
  }

  @override
  void onRemove() {
    game.gestureDetectors.remove<ScaleGestureRecognizer>();
    super.onRemove();
  }
}
