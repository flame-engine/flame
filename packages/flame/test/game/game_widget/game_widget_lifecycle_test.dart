import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MyGame extends Game {
  final List<String> events;

  MyGame(this.events);

  @override
  void update(double dt) {}

  @override
  void render(Canvas canvas) {}

  @override
  void onAttach() {
    super.onAttach();

    events.add('attach');
  }

  @override
  void onDetach() {
    super.onDetach();

    events.add('detach');
  }
}

class TitlePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(
        child: const Text('Play'),
        onPressed: () {
          Navigator.of(context).pushNamed('/game');
        },
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  final List<String> events;

  const GamePage(this.events);

  @override
  State<StatefulWidget> createState() {
    return _GamePageState();
  }
}

class _GamePageState extends State<GamePage> {
  late MyGame _game;

  @override
  void initState() {
    super.initState();

    _game = MyGame(widget.events);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GameWidget(
              game: _game,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: ElevatedButton(
              child: const Text('Back'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final List<String> events;

  const MyApp(this.events);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (_) => TitlePage(),
        '/game': (_) => GamePage(events),
      },
    );
  }
}

void main() {
  group('Game Widget - Lifecycle', () {
    testWidgets('attach upon navigation', (tester) async {
      final events = <String>[];
      await tester.pumpWidget(MyApp(events));

      await tester.tap(find.text('Play'));

      // I am unsure why I need two bumps here, my best theory is
      // that we need the first one for the navigation animation
      // and the second one for the page to render
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump(const Duration(milliseconds: 1000));

      expect(events, ['attach']);
    });

    testWidgets('detach when navigating out of the page', (tester) async {
      final events = <String>[];
      await tester.pumpWidget(MyApp(events));

      await tester.tap(find.text('Play'));

      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump(const Duration(milliseconds: 1000));

      await tester.tap(find.text('Back'));

      // This ensures that Flame is not running anymore after the navigation
      // happens, if it was, then the pumpAndSettle would break with a timeout
      await tester.pumpAndSettle();

      expect(events, ['attach', 'detach']);
    });
  });
}
