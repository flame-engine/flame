import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _MyGame(final List<String> events) extends FlameGame {
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    events.add('onGameResize');
  }

  @override
  Future<void>? onLoad() {
    events.add('onLoad');
    return null;
  }

  @override
  void onMount() {
    events.add('onMount');
  }

  @override
  void update(double dt) {
    super.update(dt);
    events.add('update');
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    events.add('render');
  }

  @override
  void onRemove() {
    super.onRemove();
    events.add('onRemove');
  }

  @override
  void onDispose() {
    super.onDispose();
    events.add('onDispose');
  }
}

class const _TitlePage() extends StatelessWidget {
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

class const _GamePage(final _MyGame game) extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GamePageState();
  }
}

class _GamePageState() extends State<_GamePage> {
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
            left: 0,
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

class _MyApp(final List<String> events) extends StatelessWidget {
  late final _MyGame game;

  this {
    game = _MyGame(events);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (_) => const _TitlePage(),
        '/game': (_) => _GamePage(game),
      },
    );
  }
}

class const _MyContainer(final List<String> events) extends StatefulWidget {
  @override
  State<_MyContainer> createState() => _MyContainerState();
}

class _MyContainerState() extends State<_MyContainer> {
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
      expect(
        events.contains('onDispose'),
        true,
        reason: 'onDispose was not called',
      );
    });

    testWidgets('on resize, parents are kept', (tester) async {
      final events = <String>[];
      await tester.pumpWidget(_MyContainer(events));

      // This ensures that the game is attached.
      await tester.pump();

      events.clear();
      final state = tester.state<_MyContainerState>(find.byType(_MyContainer));
      state.causeResize();

      await tester.pump();
      expect(
        events,
        [
          // additional because of the initial pump to ensure attachment
          'update',
          'onGameResize',
          'update',
          'render',
        ],
      ); // no onRemove
      final game = tester.allWidgets
          .whereType<GameWidget<_MyGame>>()
          .first
          .game;
      expect(game?.children, everyElement((Component c) => c.parent == game));
    });

    testWidgets('update is not called when game is paused', (tester) async {
      final events = <String>[];
      await tester.pumpWidget(_MyContainer(events));

      events.clear();
      tester.allWidgets
          .whereType<GameWidget<_MyGame>>()
          .first
          .game
          ?.pauseEngine();
      await tester.pump();
      await tester.pump();
      expect(events, ['render']);
    });

    testWidgets('all events are executed in the correct order', (tester) async {
      final events = <String>[];
      await tester.pumpWidget(_MyApp(events));

      await tester.tap(find.text('Play'));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16), EnginePhase.paint);

      await tester.tap(find.text('Back'));

      // This ensures that Flame is not running anymore after the navigation
      // happens, if it was, then the pumpAndSettle would break with a timeout
      await tester.pumpAndSettle();

      expect(
        events,
        [
          'onGameResize',
          'onLoad',
          'onMount',
          'update',
          'render',
          'update',
          'render',
          'update',
          'onRemove',
          'onDispose',
        ],
      );

      await tester.tap(find.text('Play'));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16), EnginePhase.paint);

      expect(events, [
        'onGameResize',
        'onLoad',
        'onMount',
        'update',
        'render',
        'update',
        'render',
        'update',
        'onRemove',
        'onDispose',
        'onGameResize',
        'onMount',
        'update',
        'render',
      ]);
    });
  });
}
