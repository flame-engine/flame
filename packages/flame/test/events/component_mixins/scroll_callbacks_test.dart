import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScrollCallbacks', () {
    testWithFlameGame(
      'make sure ScrollCallbacks components can be added to a FlameGame',
      (game) async {
        await game.ensureAdd(_ScrollCallbacksComponent());
        await game.ready();

        _hasDispatcher(game);
      },
    );

    testWithFlameGame('receive scroll events on component', (game) async {
      final c1 = _ScrollCallbacksComponent(
        position: Vector2.all(10),
        size: Vector2.all(10),
      );
      game.add(c1);
      final c2 = _ScrollCallbacksComponent(
        position: Vector2.all(15),
        size: Vector2.all(10),
      );
      game.add(c2);

      await game.ready();

      _hasDispatcher(game);

      // Scroll at position inside c1 only
      _scrollEvent(game, Vector2.all(12), Vector2(0, 10));
      expect(c1.receivedScrolls, hasLength(1));
      expect(c1.receivedScrolls.last.localPosition, Vector2.all(2));
      expect(c1.receivedScrolls.last.scrollDelta, Vector2(0, 10));
      expect(c2.receivedScrolls, isEmpty);

      c1.receivedScrolls.clear();

      // Scroll at position outside both
      _scrollEvent(game, Vector2.all(1), Vector2(0, 5));
      expect(c1.receivedScrolls, isEmpty);
      expect(c2.receivedScrolls, isEmpty);

      // Scroll at position inside both c1 and c2 (overlapping area)
      _scrollEvent(game, Vector2.all(19), Vector2(0, -5));
      expect(c1.receivedScrolls, hasLength(1));
      expect(c1.receivedScrolls.last.localPosition, Vector2.all(9));
      expect(c2.receivedScrolls, hasLength(1));
      expect(c2.receivedScrolls.last.localPosition, Vector2.all(4));

      c1.receivedScrolls.clear();
      c2.receivedScrolls.clear();

      // Scroll at position inside c2 only
      _scrollEvent(game, Vector2.all(21), Vector2(10, 0));
      expect(c1.receivedScrolls, isEmpty);
      expect(c2.receivedScrolls, hasLength(1));
      expect(c2.receivedScrolls.last.localPosition, Vector2.all(6));
    });

    testWithGame(
      'receive scroll events on game',
      _ScrollCallbacksGame.new,
      (game) async {
        _hasDispatcher(game);

        _scrollEvent(game, Vector2.all(12), Vector2(0, 10));
        expect(game.receivedScrolls, hasLength(1));
        expect(game.receivedScrolls.last.localPosition, Vector2.all(12));
        expect(game.receivedScrolls.last.scrollDelta, Vector2(0, 10));
      },
    );

    testWithFlameGame(
      'scroll events have correct raw event',
      (game) async {
        final component = _RawScrollCallbacksComponent(
          position: Vector2.zero(),
          size: Vector2.all(100),
        );
        await game.ensureAdd(component);
        await game.ready();

        _scrollEvent(game, Vector2.all(10), Vector2(0, 20));
        expect(component.rawEventReceived, isTrue);
      },
    );

    testWithFlameGame(
      'continuePropagation controls scroll delivery',
      (game) async {
        final top = _ScrollCallbacksComponent(
          position: Vector2.all(10),
          size: Vector2.all(20),
        );
        final bottom = _ScrollCallbacksComponent(
          position: Vector2.all(10),
          size: Vector2.all(20),
        );
        // bottom is added first, top is rendered on top
        game.add(bottom);
        game.add(top);
        await game.ready();

        // By default, deliverToAll is true for scroll, so both get events
        _scrollEvent(game, Vector2.all(15), Vector2(0, 10));
        expect(top.receivedScrolls, hasLength(1));
        expect(bottom.receivedScrolls, hasLength(1));
      },
    );
  });
}

void _scrollEvent(FlameGame game, Vector2 position, Vector2 scrollDelta) {
  game.firstChild<ScrollDispatcher>()!.onPointerScroll(
    createScrollEvent(
      game: game,
      position: position,
      scrollDelta: scrollDelta,
    ),
  );
}

void _hasDispatcher(FlameGame game) {
  expect(
    game.children.whereType<ScrollDispatcher>(),
    hasLength(1),
  );
}

mixin _ScrollInspector on ScrollCallbacks {
  List<({Vector2 localPosition, Vector2 scrollDelta})> receivedScrolls = [];

  @override
  void onScroll(ScrollEvent event) {
    expect(event.raw, isNotNull);
    receivedScrolls.add((
      localPosition: event.localPosition.clone(),
      scrollDelta: event.scrollDelta.clone(),
    ));
  }
}

class _ScrollCallbacksComponent extends PositionComponent
    with ScrollCallbacks, _ScrollInspector {
  _ScrollCallbacksComponent({
    super.position,
    super.size,
  });
}

class _ScrollCallbacksGame extends FlameGame
    with ScrollCallbacks, _ScrollInspector {}

class _RawScrollCallbacksComponent extends PositionComponent
    with ScrollCallbacks {
  _RawScrollCallbacksComponent({super.position, super.size});

  bool rawEventReceived = false;

  @override
  void onScroll(ScrollEvent event) {
    rawEventReceived = true;
  }
}
