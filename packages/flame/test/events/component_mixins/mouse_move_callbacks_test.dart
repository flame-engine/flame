import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MouseMoveCallbacks', () {
    testWithFlameGame(
      'make sure MouseMoveCallbacks components can be added to a FlameGame',
      (game) async {
        await game.ensureAdd(_MouseMoveCallbacksComponent());
        await game.ready();

        _hasDispatcher(game);
      },
    );

    testWithFlameGame('receive pointer move events on component', (game) async {
      final c1 = _MouseMoveCallbacksComponent(
        position: Vector2.all(10),
        size: Vector2.all(10),
      );
      game.add(c1);
      final c2 = _MouseMoveCallbacksComponent(
        position: Vector2.all(15),
        size: Vector2.all(10),
      );
      game.add(c2);

      await game.ready();

      _hasDispatcher(game);

      _mouseEvent(game, Vector2.all(12));
      expect(c1.removeSingle(), Vector2.all(2));
      expect(c2.receivedEventsAt, isEmpty);

      _mouseEvent(game, Vector2.all(1));
      expect(c1.receivedEventsAt, isEmpty);
      expect(c2.receivedEventsAt, isEmpty);

      _mouseEvent(game, Vector2.all(19));
      expect(c1.removeSingle(), Vector2.all(9));
      expect(c2.removeSingle(), Vector2.all(4));

      _mouseEvent(game, Vector2.all(21));
      expect(c1.receivedEventsAt, isEmpty);
      expect(c2.removeSingle(), Vector2.all(6));
    });

    testWithGame(
      'receive pointer move events on game',
      _MouseMoveCallbacksGame.new,
      (game) async {
        _hasDispatcher(game);

        _mouseEvent(game, Vector2.all(12));
        expect(game.removeSingle(), Vector2.all(12));

        _mouseEvent(game, Vector2.all(1));
        expect(game.removeSingle(), Vector2.all(1));

        _mouseEvent(game, Vector2.all(19));
        expect(game.removeSingle(), Vector2.all(19));

        _mouseEvent(game, Vector2.all(21));
        expect(game.removeSingle(), Vector2.all(21));
      },
    );
  });
}

void _mouseEvent(FlameGame game, Vector2 position) {
  game.firstChild<MouseMoveDispatcher>()!.onMouseMove(
    createMouseMoveEvent(
      game: game,
      position: position,
    ),
  );
}

void _hasDispatcher(FlameGame game) {
  expect(
    game.children.whereType<MouseMoveDispatcher>(),
    hasLength(1),
  );
}

mixin _MouseMoveInspector on MouseMoveCallbacks {
  List<Vector2> receivedEventsAt = [];

  Vector2 removeSingle() {
    expect(receivedEventsAt, hasLength(1));
    return receivedEventsAt.removeAt(0);
  }

  @override
  void onMouseMove(MouseMoveEvent event) {
    expect(event.raw, isNotNull);
    receivedEventsAt.add(event.localPosition);
  }
}

class _MouseMoveCallbacksComponent extends PositionComponent
    with MouseMoveCallbacks, _MouseMoveInspector {
  _MouseMoveCallbacksComponent({
    super.position,
    super.size,
  });
}

class _MouseMoveCallbacksGame extends FlameGame
    with MouseMoveCallbacks, _MouseMoveInspector {}
