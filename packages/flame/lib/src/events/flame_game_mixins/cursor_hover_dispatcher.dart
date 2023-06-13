import 'package:flame/src/components/core/component.dart';
import 'package:flame/src/events/component_mixins/cursor_hover_callbacks.dart';
import 'package:flame/src/events/messages/cursor_hover_event.dart';
import 'package:flame/src/game/flame_game.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

@internal
class CursorHoverDispatcher extends Component {
  bool _eventHandlerRegistered = false;
  FlameGame get game => parent! as FlameGame;

  @mustCallSuper
  void onMouseMove(CursorHoverEvent event) {
    event.deliverAtPoint(
      rootComponent: game,
      eventHandler: (CursorHoverCallbacks component) {
        component.onMouseMove(event);
      },
    );
  }

  @internal
  void handleMouseMove(int pointerId, PointerHoverEvent pointerHoverEvent) {
    onMouseMove(CursorHoverEvent(pointerId, pointerHoverEvent));
  }

  @override
  void onMount() {
    if (game.firstChild<CursorHoverDispatcher>() == null) {
      // TODO: Add detector to game
      // game.gestureDetectors.add(
      //   PointerHoverEventListener.new,
      //   () {},
      // );
    } else {
      removeFromParent();
    }
  }
}
