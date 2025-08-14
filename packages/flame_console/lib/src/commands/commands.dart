import 'package:args/args.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_console/src/commands/commands.dart';
import 'package:flame_console/src/commands/pause_command.dart';
import 'package:flame_console/src/commands/resume_command.dart';
import 'package:terminui/terminui.dart';

export 'package:args/args.dart' show ArgResults;

export 'debug_command.dart';
export 'ls_command.dart';
export 'remove_command.dart';

abstract class FlameConsoleCommand<T extends FlameGame>
    extends TerminuiCommand<T> {
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
    List<String> ids = const [],
    List<String> types = const [],
    int? limit,
  }) {
    final components = listAllChildren(rootComponent);

    var count = 0;

    for (final element in components) {
      if (limit != null && count >= limit) {
        break;
      }

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
}

abstract class QueryCommand<G extends FlameGame>
    extends FlameConsoleCommand<G> {
  (String?, String) processChildren(List<Component> children);

  @override
  (String?, String) execute(G game, ArgResults results) {
    final children = <Component>[];

    onChildMatch(
      children.add,
      rootComponent: game,
      ids: results['id'] as List<String>? ?? [],
      types: results['type'] as List<String>? ?? [],
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

class FlameConsoleCommands {
  static List<FlameConsoleCommand> commands = [
    LsConsoleCommand(),
    RemoveConsoleCommand(),
    DebugConsoleCommand(),
    PauseConsoleCommand(),
    ResumeConsoleCommand(),
  ];
}
