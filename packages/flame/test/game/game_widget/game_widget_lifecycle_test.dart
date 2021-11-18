import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _MyGame extends FlameGame {
  final List<String> events;

  _MyGame(this.events);

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

class _TitlePage extends StatelessWidget {
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

class _GamePage extends StatefulWidget {
  final _MyGame game;

  const _GamePage(this.game);

  @override
  State<StatefulWidget> createState() {
    return _GamePageState();
  }
}

class _GamePageState extends State<_GamePage> {
  late _MyGame _game;

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

class _MyApp extends StatelessWidget {
  final List<String> events;
  late final _MyGame game;

  _MyApp(this.events) {
    game = _MyGame(events);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (_) => _TitlePage(),
        '/game': (_) => _GamePage(game),
      },
    );
  }
}

class _MyContainer extends StatefulWidget {
  final List<String> events;

  const _MyContainer(this.events, {Key? key}) : super(key: key);

  @override
  State<_MyContainer> createState() => _MyContainerState();
}

class _MyContainerState extends State<_MyContainer> {
  double size = 300;

  late final game = _MyGame(widget.events);

  void causeResize() {
    setState(() => size = 400);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: GameWidget(game: game),
    );
  }
}

void main() {
  group('Game Widget - Lifecycle', () {
    testWidgets('attach upon navigation', (tester) async {
      final events = <String>[];
      await tester.pumpWidget(_MyApp(events));

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
      await tester.pumpWidget(_MyApp(events));

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

    testWidgets('on resize, parents are kept', (tester) async {
      final events = <String>[];
      await tester.pumpWidget(_MyContainer(events));

      events.clear();
      final state = tester.state<_MyContainerState>(find.byType(_MyContainer));
      state.causeResize();

      await tester.pump();
      expect(events, ['onGameResize']); // no onRemove
      final game =
          tester.allWidgets.whereType<GameWidget<_MyGame>>().first.game;
      expect(game.children, everyElement((Component c) => c.parent == game));
    });

    testWidgets('all events are executed in the correct order', (tester) async {
      final events = <String>[];
      await tester.pumpWidget(_MyApp(events));

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
