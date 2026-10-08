import 'package:flame/game.dart';
import 'package:flame/src/devtools/connectors/component_count_connector.dart';
import 'package:flame/src/devtools/connectors/component_snapshot_connector.dart';
import 'package:flame/src/devtools/connectors/component_tree_connector.dart';
import 'package:flame/src/devtools/connectors/debug_mode_connector.dart';
import 'package:flame/src/devtools/connectors/game_loop_connector.dart';
import 'package:flame/src/devtools/connectors/game_snapshot_connector.dart';
import 'package:flame/src/devtools/connectors/image_cache_connector.dart';
import 'package:flame/src/devtools/connectors/input_connector.dart';
import 'package:flame/src/devtools/connectors/overlay_navigation_connector.dart';
import 'package:flame/src/devtools/connectors/position_component_attributes_connector.dart';
import 'package:flame/src/devtools/dev_tools_connector.dart';

/// When [DevToolsService] is initialized by the [FlameGame] it will call
/// the `init` method for all [DevToolsConnector]s so that they can register
/// service extensions which are the ones that makes it possible for the
/// devtools extension to communicate with the game.
///
/// Do note that if you have multiple games in your app, only the last one
/// created will be connected to the devtools. If you want to change it to
/// another game instance you can call [DevToolsService.initWithGame] with
/// the game instance that you want to observe.
class DevToolsService._() {
  static final instance = DevToolsService._();

  /// Initializes the service with the given game instance.
  factory DevToolsService.initWithGame(FlameGame game) {
    instance.initGame(game);
    return instance;
  }

  FlameGame? _game;
  FlameGame get game => _game!;

  /// The list of available connectors.
  ///
  /// The connectors of Flame are in this list from the start. A connector from
  /// another package, which should be available after the game was created,
  /// is added with [registerConnector].
  final connectors = <DevToolsConnector>[
    DebugModeConnector(),
    ComponentCountConnector(),
    ComponentTreeConnector(),
    GameLoopConnector(),
    ComponentSnapshotConnector(),
    GameSnapshotConnector(),
    PositionComponentAttributesConnector(),
    OverlayNavigationConnector(),
    InputConnector(),
    ImageCacheConnector(),
  ];

  /// Adds [connector] to the [connectors], so that it is told about the game
  /// that is observed now and about the games that are set later.
  ///
  /// This is how a package that is built on top of Flame can expose its own
  /// information to the devtools extension. The service extensions of the
  /// connector are registered when it is created, which has to happen only
  /// once, so create it inside a guard.
  void registerConnector(DevToolsConnector connector) {
    connectors.add(connector);
    final game = _game;
    if (game != null) {
      connector.initGame(game);
    }
  }

  /// This method is called every time a new game is set in the service and it
  /// is responsible for calling the [DevToolsConnector.initGame] method in all
  /// the connectors. It is also responsible for calling
  /// [DevToolsConnector.disposeGame] of all connectors when a new game is set,
  /// if there was a game set previously.
  void initGame(FlameGame game) {
    if (_game != null) {
      for (final connector in connectors) {
        connector.disposeGame();
      }
    }

    _game = game;
    for (final connector in connectors) {
      connector.initGame(game);
    }
  }
}
