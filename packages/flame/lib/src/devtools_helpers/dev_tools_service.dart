import 'package:flame/game.dart';
import 'package:flame/src/devtools_helpers/connectors/component_count_connector.dart';
import 'package:flame/src/devtools_helpers/connectors/debug_mode_connector.dart';
import 'package:flame/src/devtools_helpers/connectors/game_loop_connector.dart';
import 'package:flame/src/devtools_helpers/dev_tools_connector.dart';

/// When [DevToolsService] is initialized by the [FlameGame] it will call
/// the `init` method for all [DevToolsConnector]s so that they can register
/// service extensions which are the ones that makes it possible for the
/// devtools extension to communicate with the game.
///
/// Do note that if you have multiple games in your app, only the last one
/// created will be connected to the devtools. If you want to change it to
/// another game instance you can call [DevToolsService.initWithGame] with
/// the game instance that you want to observe.
class DevToolsService {
  DevToolsService._();

  static final instance = DevToolsService._();

  /// Initializes the service with the given game instance.
  factory DevToolsService.initWithGame(FlameGame game) {
    instance.game = game;
    instance.initGame();
    return instance;
  }

  late FlameGame game;

  /// The list of available connectors, remember to add your connector here if
  /// you create a new one.
  final connectors = [
    DebugModeConnector(),
    ComponentCountConnector(),
    GameLoopConnector(),
  ];

  /// This method is called every time a new game is set in the service and it
  /// is responsible for calling the [DevToolsConnector.initGame] method in all
  /// the connectors.
  void initGame() {
    for (final connector in connectors) {
      connector.initGame(game);
    }
  }
}
