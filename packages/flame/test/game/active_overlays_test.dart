import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('_ActiveOverlays', () {
    group('add', () {
      test('can add an overlay', () {
        final overlays = FlameGame().overlays;
        final added = overlays.add('test');
        expect(added, true);
        expect(overlays.isActive('test'), true);
      });

      test('wont add same overlay', () {
        final overlays = FlameGame().overlays;
        overlays.add('test');
        final added = overlays.add('test');
        expect(added, false);
      });
    });

    group('addAll', () {
      test('can add multiple overlays at once', () {
        final overlays = FlameGame().overlays;
        overlays.addAll(['test', 'test2']);
        expect(overlays.isActive('test'), true);
        expect(overlays.isActive('test2'), true);
      });

      test('only refreshes gameWidget once if added', () {
        final game = FlameGame();
        var widgetRefreshedCount = 0;
        game.addGameStateListener(() => widgetRefreshedCount++);

        game.overlays.addAll(['test', 'test2']);

        expect(widgetRefreshedCount, 1);
      });

      test('does not refreshes gameWidget when not changed', () {
        final game = FlameGame();
        var widgetRefreshedCount = 0;
        game.overlays.addAll(['test', 'test2']);
        game.addGameStateListener(() => widgetRefreshedCount++);

        game.overlays.addAll(['test', 'test2']);

        expect(widgetRefreshedCount, 0);
      });
    });

    group('removeAll', () {
      test('can remove multiple overlays at once', () {
        final overlays = FlameGame().overlays;
        overlays.addAll(['test', 'test2']);

        overlays.removeAll(['test', 'test2']);

        expect(overlays.isActive('test'), false);
        expect(overlays.isActive('test2'), false);
      });

      test('only refreshes gameWidget once if removed', () {
        final game = FlameGame();
        var widgetRefreshedCount = 0;
        game.overlays.addAll(['test', 'test2']);
        game.addGameStateListener(() => widgetRefreshedCount++);

        game.overlays.removeAll(['test', 'test2']);

        expect(widgetRefreshedCount, 1);
      });

      test('does not refreshes gameWidget when not changed', () {
        final game = FlameGame();
        var widgetRefreshedCount = 0;
        game.overlays.removeAll(['test', 'test2']);
        game.addGameStateListener(() => widgetRefreshedCount++);

        game.overlays.removeAll(['test', 'test2']);

        expect(widgetRefreshedCount, 0);
      });
    });

    group('remove', () {
      test('can remove an overlay', () {
        final overlays = FlameGame().overlays;
        overlays.add('test');

        final removed = overlays.remove('test');
        expect(removed, true);
        expect(overlays.isActive('test'), false);
      });

      test('will not result in removal if there is nothing to remove', () {
        final overlays = FlameGame().overlays;
        final removed = overlays.remove('test');
        expect(removed, false);
      });
    });

    group('isActive', () {
      test('is true when overlay is active', () {
        final overlays = FlameGame().overlays;
        overlays.add('test');
        expect(overlays.isActive('test'), true);
      });

      test('is false when overlay is active', () {
        final overlays = FlameGame().overlays;
        expect(overlays.isActive('test'), false);
      });
    });

    group('clear', () {
      test('clears all overlays', () {
        final overlays = FlameGame().overlays;
        overlays.add('test1');
        overlays.add('test2');

        overlays.clear();

        expect(overlays.isActive('test1'), false);
        expect(overlays.isActive('test2'), false);
      });
    });
  });
}
