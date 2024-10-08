import 'package:args/args.dart';
import 'package:flame/game.dart';
import 'package:flame_console/flame_console.dart';

class PauseConsoleCommand<G extends FlameGame> extends ConsoleCommand<G> {
  @override
  (String?, String) execute(G game, ArgResults results) {
    if (game.paused) {
      return ('Game is already paused', '');
    } else {
      game.pauseEngine();
      return (null, '');
    }
  }

  @override
  ArgParser get parser => ArgParser();
}
