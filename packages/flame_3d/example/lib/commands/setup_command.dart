import 'package:example/commands/destroy_command.dart';
import 'package:example/example_game_3d.dart';
import 'package:example/scenarios/game_scenario.dart';
import 'package:flame_console/flame_console.dart';

class SetupCommand extends FlameConsoleCommand<ExampleGame3D> {
  @override
  String get name => 'setup';

  @override
  String get description => 'Sets up the game world';

  @override
  (String?, String) execute(ExampleGame3D game, ArgResults args) {
    final scenarioName = args.arguments.firstOrNull;
    if (scenarioName == null) {
      return ('No scenario name provided.', '');
    }

    final scenario = GameScenario.scenarios[scenarioName];
    if (scenario == null) {
      return ('Unknown scenario: $scenarioName', '');
    }

    DestroyCommand.destroyMatching(game, (_) => true);
    scenario.setup(game);
    return (null, 'Scenario $scenarioName has been set up.');
  }
}
