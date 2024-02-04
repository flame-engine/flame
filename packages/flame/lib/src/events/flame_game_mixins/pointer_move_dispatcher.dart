import 'package:flame/events.dart';
import 'package:flame/src/components/core/component.dart';
import 'package:flame/src/components/core/component_key.dart';
import 'package:flame/src/events/tagged_component.dart';
import 'package:flame/src/game/flame_game.dart';
import 'package:flutter/gestures.dart' as flutter;
import 'package:meta/meta.dart';

/// **MouseMoveDispatcher** facilitates dispatching of mouse move events to the
/// [PointerMoveCallbacks] components in the component tree. It will be attached
/// to the [FlameGame] instance automatically whenever any
/// [PointerMoveCallbacks] components are mounted into the component tree.
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
        component.onPointerMove(event);
      },
    );

    final toRemove = <TaggedComponent<PointerMoveCallbacks>>{};
    for (final record in _records) {
      if (record.pointerId == event.pointerId && !updated.contains(record)) {
        // one last "exit" event
        record.component.onPointerMoveStop(event);
        toRemove.add(record);
      }
    }
    _records.removeAll(toRemove);
  }

  void _handlePointerMove(flutter.PointerHoverEvent event) {
    onMouseMove(PointerMoveEvent.fromPointerHoverEvent(game, event));
  }

  @override
  void onMount() {
    game.mouseDetector = _handlePointerMove;
  }

  @override
  void onRemove() {
    game.mouseDetector = null;
    game.unregisterKey(const MouseMoveDispatcherKey());
  }
}

class MouseMoveDispatcherKey implements ComponentKey {
  const MouseMoveDispatcherKey();

  @override
  int get hashCode => 'MouseMoveDispatcherKey'.hashCode;

  @override
  bool operator ==(Object other) =>
      other is MouseMoveDispatcherKey && other.hashCode == hashCode;
}
