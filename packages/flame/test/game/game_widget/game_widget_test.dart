import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Wrapper extends StatefulWidget {
  const _Wrapper({
    required this.child,
    this.open = false,
  });

  final Widget child;
  final bool open;

  @override
  State<_Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<_Wrapper> {
  late bool _open;

  @override
  void initState() {
    super.initState();

    _open = widget.open;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            if (_open) Expanded(child: widget.child),
            ElevatedButton(
              child: const Text('Toggle'),
              onPressed: () {
                setState(() => _open = !_open);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MyGame extends FlameGame {
  bool onAttachCalled = false;
  bool onDetachCalled = false;

  @override
  void onAttach() {
    super.onAttach();

    onAttachCalled = true;
  }

  @override
  void onDetach() {
    super.onDetach();

    onDetachCalled = true;
  }
}

FlameTester<_MyGame> myGame({required bool open}) {
  return FlameTester(
    _MyGame.new,
    pumpWidget: (gameWidget, tester) async {
      await tester.pumpWidget(_Wrapper(child: gameWidget, open: open));
    },
  );
}

void main() {
  myGame(open: false).testGameWidget(
    'calls onAttach when it enters the tree and onDetach and it leaves',
    verify: (game, tester) async {
      expect(game.onAttachCalled, isFalse);

      await tester.tap(find.text('Toggle'));
      // First will be the build of the wrapper
      await tester.pump();
      // Second will be the build of the game widget itself
      await tester.pump();

      expect(game.onAttachCalled, isTrue);
      expect(game.onDetachCalled, isFalse);

      await tester.tap(find.text('Toggle'));
      await tester.pump();

      expect(game.onDetachCalled, isTrue);
    },
  );

  myGame(open: true).testGameWidget(
    'size is kept on game after a detach',
    verify: (game, tester) async {
      expect(game.hasLayout, isTrue);

      await tester.tap(find.text('Toggle'));
      await tester.pump();

      expect(game.isAttached, isFalse);
      expect(game.size, isNotNull);
      expect(game.hasLayout, isTrue);
    },
  );

  testWidgets('Subscription is valid after game change', (tester) async {
    const key = Key('flame-game');
    final game1 = FlameGame();
    await tester.pumpWidget(GameWidget(key: key, game: game1));
    expect(game1.isMounted, true);
    expect(game1.gameStateListeners.length, 1);

    final game2 = FlameGame();
    await tester.pumpWidget(GameWidget(key: key, game: game2));
    final widget = tester.firstWidget<GameWidget>(
      find.byWidgetPredicate((widget) => widget is GameWidget),
    );
    expect(widget.game, game2);
    expect(game2.isMounted, true);
    expect(game2.gameStateListeners.length, 1);
    expect(game1.gameStateListeners.length, 0);
  });
}
