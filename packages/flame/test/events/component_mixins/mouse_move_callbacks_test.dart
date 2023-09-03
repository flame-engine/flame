import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/src/events/flame_game_mixins/pointer_move_dispatcher.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PointerMoveCallbacks', () {
    testWithFlameGame(
        'make sure PointerMoveCallbacks components can be added to a FlameGame',
        (game) async {
      await game.ensureAdd(_PointerMoveCallbacksComponent());
      await game.ready();
      expect(game.children.toList()[1], isA<PointerMoveDispatcher>());
    });

    testWithFlameGame('receive pointer move events', (game) async {
      final component = _PointerMoveCallbacksComponent()
        ..position = Vector2.all(10)
        ..size = Vector2.all(10);
      game.add(component);
      await game.ready();

      expect(
        game.children.whereType<PointerMoveDispatcher>().length,
        equals(1),
      );
      game.firstChild<PointerMoveDispatcher>()!.onMouseMove(
            createMouseMoveEvent(
              game: game,
              position: Vector2.all(12),
            ),
          );
      final receivedEvent = component.events.single;
      expect(receivedEvent.canvasPosition, Vector2.all(12));
    });
  });
}

mixin _PointerMoveInspector on PointerMoveCallbacks {
  List<PointerMoveEvent> events = [];

  @override
  void onPointerMoveEvent(PointerMoveEvent event) {
    events.add(event);
  }
}

class _PointerMoveCallbacksComponent extends PositionComponent
    with PointerMoveCallbacks,_PointerMoveInspector {}

class _PointerMoveCallbacksGame extends FlameGame
    with PointerMoveCallbacks, _PointerMoveInspector {}
