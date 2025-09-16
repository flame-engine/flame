import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final numberProvider = Provider.autoDispose((ref) {
  return 1;
});

class MyGame extends FlameGame with RiverpodGameMixin {}

class MyGameWithRefAccess extends FlameGame with RiverpodGameMixin {
  @override
  void onMount() {
    addToGameWidgetBuild(() {
      ref.watch(numberProvider);
    });
    super.onMount();
  }
}

class EmptyComponent extends Component with RiverpodComponentMixin {
  @override
  void onLoad() {
    super.onLoad();
    addToGameWidgetBuild(() {
      // do nothing
    });
  }
}

class WatchingComponent extends Component with RiverpodComponentMixin {
  @override
  void onLoad() {
    super.onLoad();
    addToGameWidgetBuild(() {
      ref.watch(numberProvider);
    });
  }
}

void main() {
  testWidgets(
    'Test registration and de-registration of GameWidget build callbacks',
    (widgetTester) async {
      final game = MyGame();
      final component = EmptyComponent();
      final key = GlobalKey<RiverpodAwareGameWidgetState>();

      await widgetTester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: RiverpodAwareGameWidget(
              game: game,
              key: key,
            ),
          ),
        ),
      );
      await widgetTester.pump(const Duration(seconds: 5));

      expect(game.hasBuildCallbacks, false);

      // Add the custom component
      game.add(component);

      // Expect the game is ready to play
      expect(game.isAttached, true);
      expect(game.isMounted, true);
      expect(game.isLoaded, true);

      // Pump to ensure the custom component's lifecycle events are handled
      await widgetTester.pump(const Duration(seconds: 1));

      // Expect the component has added a callback for the game widget's build
      // method.
      expect(game.hasBuildCallbacks, true);

      // Remove the custom component.
      game.remove(component);

      // Pump to ensure the component has been removed.
      await widgetTester.pump(Duration.zero);

      // When the component is removed there should be no onBuild callbacks
      // remaining.
      expect(game.hasBuildCallbacks, false);

      // When the component is removed, there should be no game reference on the
      // component.
      expect(component.ref.game == null, true);
    },
  );

  testWidgets('Test registration and de-registration of Provider listeners', (
    widgetTester,
  ) async {
    final game = MyGame();
    final component = WatchingComponent();
    final key = GlobalKey<RiverpodAwareGameWidgetState>();

    await widgetTester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: RiverpodAwareGameWidget(
            game: game,
            key: key,
          ),
        ),
      ),
    );
    await widgetTester.pump(const Duration(seconds: 5));

    // Expect that the GameWidget is not initially listening to
    // numberProvider
    expect(key.currentState?.exists(numberProvider), false);

    // Add the custom component
    game.add(component);

    // Expect the game is ready to play
    expect(game.isAttached, true);
    expect(game.isMounted, true);
    expect(game.isLoaded, true);

    // Pump to ensure the custom component's lifecycle events are handled
    await widgetTester.pump(Duration.zero);

    // Expect that the GameWidget is now listening to
    // numberProvider as the watching component has been added.
    expect(key.currentState?.exists(numberProvider), true);

    // Remove the custom component from the game.
    game.remove(component);

    // Pump to ensure the component has been removed.
    await widgetTester.pump(Duration.zero);

    // Expect the component has been removed from the game.
    expect(component.isRemoved, true);

    // Pump to ensure the listener has been cancelled by ProviderScope.
    await widgetTester.pump(const Duration(seconds: 5));

    // Expect that the GameWidget is no longer listening to
    // numberProvider as the watching component has been removed.
    expect(key.currentState?.exists(numberProvider), false);
  });

  testWidgets(
    'Test registration and de-registration of Game Provider listeners',
    (widgetTester) async {
      final game = MyGameWithRefAccess();
      final key = GlobalKey<RiverpodAwareGameWidgetState>();

      await widgetTester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: RiverpodAwareGameWidget(
              game: game,
              key: key,
            ),
          ),
        ),
      );
      await widgetTester.pump(Duration.zero);

      // Expect the game is ready to play
      expect(game.isAttached, true);
      expect(game.isMounted, true);
      expect(game.isLoaded, true);

      // Pump to ensure the custom component's lifecycle events are handled
      await widgetTester.pump(Duration.zero);

      // Expect that the GameWidget is initially listening to
      // numberProvider
      expect(key.currentState?.exists(numberProvider), true);

      // Replace the widget tree so that the GameWidget gets disposed
      await widgetTester.pumpWidget(Container());
      await widgetTester.pumpAndSettle();

      // Expect that the component has been removed from the game.
      expect(game.isAttached, false);

      // Expect that the key no longer has access to a state.
      expect(key.currentState, null);
    },
  );
}
