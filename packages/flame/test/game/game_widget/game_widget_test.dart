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

class MyGame extends FlameGame {
  bool onAttachCalled = false;
  bool onDettachCalled = false;

  @override
  void onAttach() {
    super.onAttach();

    onAttachCalled = true;
  }

  @override
  void onDetach() {
    super.onDetach();

    onDettachCalled = true;
  }
}

FlameTester<MyGame> myGame({required bool open}) {
  return FlameTester(
    () => MyGame(),
    pumpWidget: (gameWidget, tester) async {
      await tester.pumpWidget(_Wrapper(child: gameWidget, open: open));
    },
  );
}

void main() {
  myGame(open: false).widgetTest(
    'calls onAttach when it enters the tree and onDetach and it leaves',
    (game, tester) async {
      expect(game.onAttachCalled, isFalse);

      await tester.tap(find.text('Toggle'));
      // First will be the build of the wrapper
      await tester.pump();
      // Second will be the build of the game widget itself
      await tester.pump();

      expect(game.onAttachCalled, isTrue);
      expect(game.onDettachCalled, isFalse);

      await tester.tap(find.text('Toggle'));
      await tester.pump();

      expect(game.onDettachCalled, isTrue);
    },
  );
  myGame(open: true).widgetTest(
    'size is kept on game after a detach',
    (game, tester) async {
      expect(game.hasLayout, isTrue);

      await tester.tap(find.text('Toggle'));
      await tester.pump();

      expect(game.isAttached, isFalse);
      expect(game.size, isNotNull);
      expect(game.hasLayout, isTrue);
    },
  );
}
