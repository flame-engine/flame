import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_resources/custom_flame_game.dart';

void main() {
  group('_ActiveOverlays', () {
    testWidgets(
      'Overlay can be added via initialActiveOverlays',
      (tester) async {
        const key1 = ValueKey('one');
        const key2 = ValueKey('two');
        await tester.pumpWidget(
          GameWidget(
            game: FlameGame(),
            overlayBuilderMap: {
              'first!': (_, __) => Container(key: key1),
              'second': (_, __) => Container(key: key2),
            },
            initialActiveOverlays: const ['first!'],
          ),
        );
        await tester.pump();

        expect(find.byKey(key1), findsOneWidget);
        expect(find.byKey(key2), findsNothing);
      },
    );

    testWidgets(
      'Overlay can be added in onLoad',
      (tester) async {
        const key1 = ValueKey('one');
        const key2 = ValueKey('two');
        await tester.pumpWidget(
          GameWidget(
            game: CustomFlameGame(
              onLoad: (game) async {
                game.overlays.add('first!');
              },
            ),
            overlayBuilderMap: {
              'first!': (_, __) => Container(key: key1),
              'second': (_, __) => Container(key: key2),
            },
          ),
        );
        await tester.pump();

        expect(find.byKey(key1), findsOneWidget);
        expect(find.byKey(key2), findsNothing);
      },
    );

    testWidgets(
      'Overlay can be added and removed at runtime',
      (tester) async {
        const key1 = ValueKey('one');
        const key2 = ValueKey('two');
        final game = FlameGame();
        await tester.pumpWidget(
          GameWidget(
            game: game,
            overlayBuilderMap: {
              'first!': (_, __) => Container(key: key1),
              'second': (_, __) => Container(key: key2),
            },
          ),
        );
        await tester.pump();

        expect(find.byKey(key1), findsNothing);
        expect(find.byKey(key2), findsNothing);

        game.overlays.add('second');
        await tester.pump();
        expect(find.byKey(key1), findsNothing);
        expect(find.byKey(key2), findsOneWidget);

        game.overlays.remove('second');
        await tester.pump();
        expect(find.byKey(key1), findsNothing);
        expect(find.byKey(key2), findsNothing);
      },
    );

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
    });

    group('removeAll', () {
      test('can remove multiple overlays at once', () {
        final overlays = FlameGame().overlays;
        overlays.addAll(['test', 'test2']);

        overlays.removeAll(['test', 'test2']);

        expect(overlays.isActive('test'), false);
        expect(overlays.isActive('test2'), false);
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
