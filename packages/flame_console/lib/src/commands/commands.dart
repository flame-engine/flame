import 'package:args/args.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_console/src/commands/commands.dart';

export 'debug_command.dart';
export 'ls_command.dart';
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

  void onChildMatch(
    void Function(Component) onChild, {
    required Component rootComponent,
    String? id,
    String? type,
    int? limit,
  }) {
    final components = listAllChildren(rootComponent);

    var count = 0;

    for (final element in components) {
      if (limit != null && count >= limit) {
        break;
      }

      final isIdMatch = id == null || element.hashCode.toString() == id;
      final isTypeMatch =
          type == null || element.runtimeType.toString() == type;

      if (isIdMatch && isTypeMatch) {
        count++;
        onChild(element);
      }
    }
  }

  (String?, String) run(G game, List<String> args) {
    final results = parser.parse(args);
    return execute(game, results);
  }

  (String?, String) execute(G game, ArgResults results);

  int? optionalIntResult(String key, ArgResults results) {
    if (results[key] != null) {
      return int.tryParse(results[key] as String);
    }
    return null;
  }
}

abstract class QueryCommand<G extends FlameGame> extends ConsoleCommand<G> {
  void processChild(Component child);

  @override
  (String?, String) execute(G game, ArgResults results) {
    onChildMatch(
      processChild,
      rootComponent: game,
      id: results['id'] as String?,
      type: results['type'] as String?,
      limit: optionalIntResult('limit', results),
    );

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
    )
    ..addOption(
      'limit',
      abbr: 'l',
    );
}

class ConsoleCommands {
  static Map<String, ConsoleCommand> commands = {
    'ls': LsConsoleCommand(),
    'rm': RemoveConsoleCommand(),
    'debug': DebugConsoleCommand(),
  };
}
