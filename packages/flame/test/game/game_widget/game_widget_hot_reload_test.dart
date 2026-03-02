import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _HotReloadGame extends FlameGame {
  int hotReloadCount = 0;

  @override
  void onHotReload() {
    hotReloadCount++;
    super.onHotReload();
  }
}

class _HotReloadComponent extends Component {
  int hotReloadCount = 0;

  @override
  void onHotReload() {
    hotReloadCount++;
    super.onHotReload();
  }
}

class _AsyncLoadComponent extends Component {
  final Completer<void> loadCompleter = Completer<void>();
  int hotReloadCount = 0;

  @override
  Future<void> onLoad() => loadCompleter.future;

  @override
  void onHotReload() {
    hotReloadCount++;
    super.onHotReload();
  }
}

GameWidgetState<_HotReloadGame> _findGameWidgetState(WidgetTester tester) {
  final state = tester.allStates
      .whereType<GameWidgetState<_HotReloadGame>>()
      .single;
  return state;
}

void main() {
  group('Game Widget - Hot Reload', () {
    testWidgets('reassemble triggers onHotReload on Game', (tester) async {
      final game = _HotReloadGame();
      await tester.pumpWidget(
        Container(
          width: 300,
          height: 300,
          child: GameWidget(game: game),
        ),
      );
      await tester.pump();

      expect(game.hotReloadCount, 0);
      _findGameWidgetState(tester).reassemble();
      expect(game.hotReloadCount, 1);
    });

    testWidgets(
      'onHotReload propagates to all mounted components',
      (tester) async {
        final game = _HotReloadGame();
        final parent = _HotReloadComponent();
        final child = _HotReloadComponent();
        parent.add(child);
        game.world.add(parent);

        await tester.pumpWidget(
          Container(
            width: 300,
            height: 300,
            child: GameWidget(game: game),
          ),
        );
        await tester.pump();

        _findGameWidgetState(tester).reassemble();

        expect(game.hotReloadCount, 1);
        expect(parent.hotReloadCount, 1);
        expect(child.hotReloadCount, 1);
      },
    );

    testWidgets(
      'onHotReload reaches components in lifecycle queue',
      (tester) async {
        final game = _HotReloadGame();
        await tester.pumpWidget(
          Container(
            width: 300,
            height: 300,
            child: GameWidget(game: game),
          ),
        );
        await tester.pump();

        final asyncComponent = _AsyncLoadComponent();
        game.world.add(asyncComponent);

        // Pump once to process the lifecycle queue and start loading
        await tester.pump();
        expect(asyncComponent.isLoading, true);

        _findGameWidgetState(tester).reassemble();

        expect(asyncComponent.hotReloadCount, 1);
      },
    );

    testWidgets(
      'onHotReload notifies queued components that are loading',
      (tester) async {
        final game = _HotReloadGame();
        await tester.pumpWidget(
          Container(
            width: 300,
            height: 300,
            child: GameWidget(game: game),
          ),
        );
        await tester.pump();

        // Add two async components - they'll start loading but stay in
        // the lifecycle queue since their onLoad hasn't completed
        final component1 = _AsyncLoadComponent();
        final component2 = _AsyncLoadComponent();
        game.world.add(component1);
        game.world.add(component2);

        await tester.pump();
        expect(component1.isLoading, true);
        expect(component2.isLoading, true);
        expect(component1.isMounted, false);
        expect(component2.isMounted, false);

        _findGameWidgetState(tester).reassemble();

        // Both queued-but-loading components should receive the notification
        expect(component1.hotReloadCount, 1);
        expect(component2.hotReloadCount, 1);
      },
    );
  });
}
