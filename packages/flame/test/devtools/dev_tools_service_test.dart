import 'package:flame/devtools.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestConnector() extends DevToolsConnector {
  final games = <FlameGame>[];
  int disposed = 0;

  @override
  void init() {}

  @override
  void initGame(FlameGame game) {
    super.initGame(game);
    games.add(game);
  }

  @override
  void disposeGame() => disposed++;
}

void main() {
  group('DevToolsService', () {
    final service = DevToolsService.instance;

    testWithFlameGame('registerConnector adds the connector', (game) async {
      final connector = _TestConnector();
      addTearDown(() => service.connectors.remove(connector));

      service.registerConnector(connector);

      expect(service.connectors, contains(connector));
    });

    testWithFlameGame(
      'registerConnector tells the connector about the current game',
      (game) async {
        final connector = _TestConnector();
        addTearDown(() => service.connectors.remove(connector));

        service.registerConnector(connector);

        expect(connector.games, [game]);
        expect(connector.game, game);
      },
    );

    testWithFlameGame(
      'a registered connector is told about the games that are set later',
      (game) async {
        final connector = _TestConnector();
        addTearDown(() => service.connectors.remove(connector));
        service.registerConnector(connector);

        // Creating a game in debug mode makes it the observed game.
        final other = FlameGame();

        expect(connector.disposed, 1);
        expect(connector.games, [game, other]);
      },
    );
  });
}
