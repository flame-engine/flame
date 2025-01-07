import 'package:args/args.dart';
import 'package:flame/game.dart';
import 'package:flame_console/flame_console.dart';

class PauseConsoleCommand<G extends FlameGame> extends FlameConsoleCommand<G> {
  @override
  (String?, String) execute(G game, ArgResults results) {
    if (game.paused) {
      return (
        'Game is already paused, use the resume command start it again',
        '',
      );
    } else {
      game.pauseEngine();
      return (null, '');
    }
  }

  @override
  ArgParser get parser => ArgParser();

  @override
  String get name => 'pause';

  @override
  String get description => 'Pauses the game loop.';
}
