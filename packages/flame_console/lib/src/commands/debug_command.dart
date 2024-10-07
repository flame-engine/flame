import 'package:args/args.dart';
import 'package:flame/game.dart';
import 'package:flame_console/src/commands/commands.dart';

class DebugConsoleCommand<G extends FlameGame> extends ConsoleCommand<G> {
  @override
  (String?, String) execute(G game, ArgResults results) {
    final components = listAllChildren(game);

    final id = results['id'] as String?;
    final type = results['type'] as String?;

    for (var element in components) {
      final isIdMatch = id == null || element.hashCode.toString() == id;
      final isTypeMatch =
          type == null || element.runtimeType.toString() == type;

      if (isIdMatch && isTypeMatch) {
        element.debugMode = true;
      }
    }

    return (null, '');
  }

  @override
  ArgParser get parser => ArgParser()
    ..addOption(
      'id',
      abbr: 'i',
    )
    ..addOption(
      'type',
      abbr: 't',
    );
}
