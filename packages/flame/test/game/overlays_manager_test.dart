import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_resources/custom_flame_game.dart';

void main() {
  group('OverlaysManager', () {
    testWidgets(
      'overlay can be added via initialActiveOverlays',
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
      'overlay can be added in onLoad',
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
      'overlay can be added and removed at runtime',
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

    test('can add an overlay', () {
      final overlays = FlameGame().overlays
        ..addEntry('test', (ctx, game) => Container());
      final added = overlays.add('test');
      expect(added, true);
      expect(overlays.isActive('test'), true);

      final added2 = overlays.add('test');
      expect(added2, false);
      expect(overlays.isActive('test'), true);
      expect(overlays.activeOverlays.length, 1);
    });

    test('can add multiple overlays at once', () {
      final overlays = FlameGame().overlays
        ..addEntry('test1', (ctx, game) => Container())
        ..addEntry('test2', (ctx, game) => Container());
      overlays.addAll(['test1', 'test2']);
      expect(overlays.isActive('test1'), true);
      expect(overlays.isActive('test2'), true);
      expect(overlays.activeOverlays.length, 2);
    });

    test('cannot add an unknown overlay', () {
      final overlays = FlameGame().overlays;
      expect(
        () => overlays.add('wheelbarrow'),
        failsAssert('Trying to add an unknown overlay "wheelbarrow"'),
      );
    });

    test('can remove an overlay', () {
      final overlays = FlameGame().overlays
        ..addEntry('test', (ctx, game) => Container());
      overlays.add('test');

      final didRemove = overlays.remove('test');
      expect(didRemove, true);
      expect(overlays.isActive('test'), false);
    });

    test('will not result in removal if there is nothing to remove', () {
      final overlays = FlameGame().overlays
        ..addEntry('test', (ctx, game) => Container());

      final didRemove = overlays.remove('test');
      expect(didRemove, false);
    });

    test('can remove multiple overlays at once', () {
      final overlays = FlameGame().overlays
        ..addEntry('test1', (ctx, game) => Container())
        ..addEntry('test2', (ctx, game) => Container())
        ..addEntry('test3', (ctx, game) => Container());
      overlays.addAll(['test1', 'test2', 'test3']);
      expect(overlays.activeOverlays.length, 3);

      overlays.removeAll(['test1', 'test2']);
      expect(overlays.isActive('test1'), false);
      expect(overlays.isActive('test2'), false);
      expect(overlays.isActive('test3'), true);
      expect(overlays.activeOverlays.length, 1);
    });

    test('clears all overlays', () {
      final overlays = FlameGame().overlays
        ..addEntry('test1', (ctx, game) => Container())
        ..addEntry('test2', (ctx, game) => Container());
      overlays.add('test1');
      overlays.add('test2');

      overlays.clear();
      expect(overlays.isActive('test1'), false);
      expect(overlays.isActive('test2'), false);
      expect(overlays.activeOverlays.length, 0);
    });
  });
}
