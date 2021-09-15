import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MyGame extends FlameGame {
  final List<String> events;

  MyGame(this.events);

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    events.add('onGameResize');
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    events.add('onLoad');
  }

  @override
  Future<void>? onMount() {
    events.add('onMount');
  }

  @override
  void onRemove() {
    super.onRemove();
    events.add('onRemove');
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
  final MyGame game;

  const GamePage(this.game);

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
    _game = widget.game;
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
  late final MyGame game;

  MyApp(this.events) {
    game = MyGame(events);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (_) => TitlePage(),
        '/game': (_) => GamePage(game),
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
      await tester.pump();
      await tester.pump();

      expect(
        events.contains('onLoad'),
        true,
        reason: 'onLoad event was not fired on attach',
      );
    });

    testWidgets('detach when navigating out of the page', (tester) async {
      final events = <String>[];
      await tester.pumpWidget(MyApp(events));

      await tester.tap(find.text('Play'));

      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Back'));

      // This ensures that Flame is not running anymore after the navigation
      // happens, if it was, then the pumpAndSettle would break with a timeout
      await tester.pumpAndSettle();

      expect(
        events.contains('onLoad'),
        true,
        reason: 'onLoad was not called',
      );
      expect(
        events.contains('onRemove'),
        true,
        reason: 'onRemove was not called',
      );
    });

    testWidgets('all events are executed in the correct order', (tester) async {
      final events = <String>[];
      await tester.pumpWidget(MyApp(events));

      await tester.tap(find.text('Play'));

      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Back'));

      // This ensures that Flame is not running anymore after the navigation
      // happens, if it was, then the pumpAndSettle would break with a timeout
      await tester.pumpAndSettle();

      await tester.tap(find.text('Play'));

      await tester.pump();
      await tester.pump();

      expect(
        events,
        [
          'onGameResize',
          'onLoad',
          'onMount',
          'onRemove',
          'onGameResize',
          'onMount',
        ],
      );
    });
  });
}
