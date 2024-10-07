import 'package:args/args.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_console/src/commands/commands.dart';

export 'ls_command.dart';
export 'debug_command.dart';
export 'remove_command.dart';

abstract class ConsoleCommand<G extends FlameGame> {
  ArgParser get parser;

  List<Component> listAllChildren(Component component) {
    return [
      for (final child in component.children) ...[
        child,
        ...listAllChildren(child),
      ],
    ];
  }

  void onChildMatch(void Function(Component) onChild,
      {required Component rootComponent, String? id, String? type}) {
    final components = listAllChildren(rootComponent);
    for (var element in components) {
      final isIdMatch = id == null || element.hashCode.toString() == id;
      final isTypeMatch =
          type == null || element.runtimeType.toString() == type;

      if (isIdMatch && isTypeMatch) {
        onChild(element);
      }
    }
  }

  (String?, String) run(G game, List<String> args) {
    final results = parser.parse(args);
    return execute(game, results);
  }

  (String?, String) execute(G game, ArgResults results);
}

class ConsoleCommands {
  static Map<String, ConsoleCommand> commands = {
    'ls': LsConsoleCommand(),
    'rm': RemoveConsoleCommand(),
    'debug': DebugConsoleCommand(),
  };
}
