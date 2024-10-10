import 'package:args/args.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_console/src/commands/commands.dart';
import 'package:flame_console/src/commands/pause_command.dart';
import 'package:flame_console/src/commands/resume_command.dart';

export 'debug_command.dart';
export 'ls_command.dart';
export 'remove_command.dart';

abstract class ConsoleCommand<G extends FlameGame> {
  ArgParser get parser;
  String get description;

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
    List<String>? ids,
    List<String>? types,
    int? limit,
  }) {
    final components = listAllChildren(rootComponent);

    var count = 0;

    for (final element in components) {
      if (limit != null && count >= limit) {
        break;
      }

      ids = ids ?? [];
      types = types ?? [];

      final isIdMatch =
          ids.isEmpty || ids.contains(element.hashCode.toString());
      final isTypeMatch =
          types.isEmpty || types.contains(element.runtimeType.toString());

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
  (String?, String) processChildren(List<Component> children);

  @override
  (String?, String) execute(G game, ArgResults results) {
    final children = <Component>[];

    onChildMatch(
      children.add,
      rootComponent: game,
      ids: results['id'] as List<String>?,
      types: results['type'] as List<String>?,
      limit: optionalIntResult('limit', results),
    );

    return processChildren(children);
  }

  @override
  ArgParser get parser => ArgParser()
    ..addMultiOption(
      'id',
      abbr: 'i',
    )
    ..addMultiOption(
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
    'pause': PauseConsoleCommand(),
    'resume': ResumeConsoleCommand(),
  };
}
