import 'package:args/args.dart';
import 'package:flame/game.dart';
import 'package:flame_console/flame_console.dart';

class ResumeConsoleCommand<G extends FlameGame> extends ConsoleCommand<G> {
  @override
  (String?, String) execute(G game, ArgResults results) {
    if (!game.paused) {
      return ('Game is not paused', '');
    } else {
      game.resumeEngine();
      return (null, '');
    }
  }

  @override
  ArgParser get parser => ArgParser();

  @override
  String get name => 'resume';

  @override
  String get description => 'Resumes the game loop.';
}
