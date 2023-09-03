import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/src/events/flame_game_mixins/pointer_move_dispatcher.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HoverCallbacks', () {
    testWithFlameGame(
        'make sure HoverCallbacks components can be added to a FlameGame',
        (game) async {
      await game.ensureAdd(_HoverCallbacksComponent());
      await game.ready();
      expect(game.children.toList()[1], isA<PointerMoveDispatcher>());
    });

    testWithFlameGame('receive mouse move events', (game) async {
      final component = _HoverCallbacksComponent()
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
      expect(component.hoverEnterEvent, equals(1));
    });
  });
}

mixin _HoverInspector on HoverCallbacks {
  int hoverEnterEvent = 0;
  int hoverExitEvent = 0;

  @override
  void onHoverEnter() {
    hoverEnterEvent++;
  }

  @override
  void onHoverExit() {
    hoverExitEvent++;
  }
}

class _HoverCallbacksComponent extends PositionComponent
    with PointerMoveCallbacks, HoverCallbacks, _HoverInspector {}

class _HoverCallbacksGame extends FlameGame
    with PointerMoveCallbacks, HoverCallbacks, _HoverInspector {}
