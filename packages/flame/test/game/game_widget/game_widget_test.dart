import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Wrapper extends StatefulWidget {
  const _Wrapper({required this.child});

  final Widget child;

  @override
  State<_Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<_Wrapper> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            if (_open) Expanded(child: widget.child),
            ElevatedButton(
              child: const Text('Toogle'),
              onPressed: () {
                setState(() {
                  _open = !_open;
                });
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

void main() {
  flameWidgetTest<MyGame>(
      'calls onAttach when it enters the tree and onDetach and it leaves',
      createGame: () => MyGame(),
      pumpWidget: (gameWidget, tester) async {
        await tester.pumpWidget(_Wrapper(child: gameWidget));
      },
      verify: (game, tester) async {
        expect(game.onAttachCalled, isFalse);

        await tester.tap(find.text('Toogle'));
        // First will be the build of the wrapper
        await tester.pump();
        // Second will be the build of the game widget itself
        await tester.pump();

        expect(game.onAttachCalled, isTrue);
        expect(game.onDettachCalled, isFalse);

        await tester.tap(find.text('Toogle'));
        await tester.pump();

        expect(game.onDettachCalled, isTrue);
      });
}
