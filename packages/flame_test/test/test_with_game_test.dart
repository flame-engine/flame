import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('testWithFlameGame', () {
    testWithFlameGame(
      'game is properly initialized',
      (game) async {
        expect(game.isLoaded, true);
        expect(game.isMounted, true);
      },
    );
  });

  group('testWithGame', () {
    List<String>? storedEvents;

    testWithGame<RecordedGame>(
      'correct event sequence',
      RecordedGame.new,
      (game) async {
        var events = <String>[];
        events = game.events;
        expect(
          events,
          ['onGameResize [800.0,600.0]', 'onLoad', 'onMount'],
        );
        // Save for the next test
        storedEvents = events;
      },
    );

    // This test may only be called after the previous test has run
    test(
      'Game.onRemove is called',
      () {
        expect(
          storedEvents,
          ['onGameResize [800.0,600.0]', 'onLoad', 'onMount', 'onRemove'],
        );
      },
    );
  });
}

class RecordedGame extends FlameGame {
  final List<String> events = [];

  @override
  void onMount() {
    super.onMount();
    events.add('onMount');
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    events.add('onLoad');
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    events.add('onGameResize $size');
  }

  @override
  void onRemove() {
    events.add('onRemove');
    super.onRemove();
  }
}
