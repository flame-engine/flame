import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('withFlameGame', () {
    test(
      'game is properly initialized',
      withFlameGame((game) async {
        // Can be fixed after #1337
        // expect(game.isLoaded, true);
        // expect(game.isMounted, true);
      }),
    );
  });

  group('withUserGame', () {
    test(
      'correct event sequence',
      () async {
        var events = <String>[];
        await withUserGame<RecordedGame>(
          () => RecordedGame(),
          (game) async {
            events = game.events;
            expect(
              events,
              ['onGameResize [800.0,600.0]', 'onLoad', 'onMount'],
            );
          },
        )();
        expect(
          events,
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
