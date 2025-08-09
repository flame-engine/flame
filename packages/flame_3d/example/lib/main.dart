import 'package:example/commands/commands.dart';
import 'package:example/example_game_3d.dart';
import 'package:example/scenarios/game_scenario.dart';
import 'package:flame/game.dart';
import 'package:flame_console/flame_console.dart';
import 'package:flutter/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GameScenario.loadAll();

  runApp(
    GameWidget.controlled(
      gameFactory: ExampleGame3D.new,
      overlayBuilderMap: {
        'console': (BuildContext context, ExampleGame3D game) {
          return FlameConsoleView(
            game: game,
            customCommands: customCommandProviders.map((it) => it()).toList(),
            onClose: () {
              game.overlays.remove('console');
            },
          );
        },
      },
    ),
  );
}
