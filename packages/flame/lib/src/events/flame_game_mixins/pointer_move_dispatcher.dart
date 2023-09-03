import 'package:flame/events.dart';
import 'package:flame/src/components/core/component.dart';
import 'package:flame/src/components/core/component_key.dart';
import 'package:flame/src/events/tagged_component.dart';
import 'package:flame/src/game/flame_game.dart';
import 'package:flutter/gestures.dart' as flutter;
import 'package:meta/meta.dart';

/// **MouseMoveDispatcher** facilitates dispatching of mouse move events to the
/// [PointerMoveCallbacks] components in the component tree. It will be attached to
/// the [FlameGame] instance automatically whenever any [PointerMoveCallbacks]
/// components are mounted into the component tree.
@internal
class PointerMoveDispatcher extends Component {
  /// The record of all components currently being hovered.
  final Set<TaggedComponent<PointerMoveCallbacks>> _records = {};

  FlameGame get game => parent! as FlameGame;

  @mustCallSuper
  void onMouseMove(PointerMoveEvent event) {
    final updated = <TaggedComponent<PointerMoveCallbacks>>{};

    event.deliverAtPoint(
      rootComponent: game,
      deliverToAll: true,
      eventHandler: (PointerMoveCallbacks component) {
        final tagged = TaggedComponent(event.pointerId, component);
        _records.add(tagged);
        updated.add(tagged);
        component.onPointerMoveEvent(event);
      },
    );

    final toRemove = <TaggedComponent<PointerMoveCallbacks>>{};
    for (final record in _records) {
      if (record.pointerId == event.pointerId && !updated.contains(record)) {
        // one last "exit" event
        record.component.onPointerMoveStopEvent(event);
        toRemove.add(record);
      }
    }
    _records.removeAll(toRemove);
  }

  void _handlePointerMove(flutter.PointerMoveEvent event) {
    onMouseMove(PointerMoveEvent.fromPointerMoveEvent(game, event));
  }

  @override
  void onMount() {
    game.gestureDetectors.add<MouseMovementGestureRecognizer>(
      () => MouseMovementGestureRecognizer(onPointerMove: _handlePointerMove),
    );
  }

  @override
  void onRemove() {
    game.gestureDetectors.remove<MouseMovementGestureRecognizer>();
    game.unregisterKey(const MouseMoveDispatcherKey());
  }
}

class MouseMoveDispatcherKey implements ComponentKey {
  const MouseMoveDispatcherKey();

  @override
  int get hashCode => 'MouseMoveDispatcherKey'.hashCode;

  @override
  bool operator ==(dynamic other) =>
      other is MouseMoveDispatcherKey && other.hashCode == hashCode;
}

class MouseMovementGestureRecognizer
    extends flutter.OneSequenceGestureRecognizer {
  void Function(flutter.PointerMoveEvent) onPointerMove;

  MouseMovementGestureRecognizer({required this.onPointerMove});

  @override
  void addPointer(flutter.PointerEvent event) {
    startTrackingPointer(event.pointer);
    _propagatePointerEvent(event);
  }

  @override
  void handleEvent(flutter.PointerEvent event) => _propagatePointerEvent(event);

  void _propagatePointerEvent(flutter.PointerEvent event) {
    if (event is flutter.PointerMoveEvent) {
      onPointerMove(event);
    }
  }

  @override
  String get debugDescription => 'mouseMovement';

  @override
  void stopTrackingPointer(int pointer) {
    super.stopTrackingPointer(pointer);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {}
}
