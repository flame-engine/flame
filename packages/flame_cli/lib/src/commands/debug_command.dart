import 'package:args/command_runner.dart';
import 'package:flame_cli/src/command_categories.dart';
import 'package:flame_cli/src/commands/flame_command.dart';
import 'package:flame_cli/src/exit_codes.dart';
import 'package:flame_cli/src/flame_connection.dart';

/// Shows or changes the debug mode of the game, or of a single component.
class DebugCommand extends FlameCommand {
  DebugCommand(super.out, super.workingDirectory) {
    argParser.addOption(
      'component',
      abbr: 'c',
      help:
          'The id of a single component to show or change the debug mode of, '
          'instead of the whole game.',
    );
  }

  @override
  String get name => 'debug';

  @override
  String get category => CommandCategories.changing;

  @override
  String get description =>
      'Show or change the debug mode, which renders hitboxes, bounds and '
      'other debug information.';

  @override
  String get invocation => 'flame debug [on|off]';

  bool? _enable;

  @override
  void validate() {
    final rest = argResults!.rest;
    _enable = switch (rest) {
      [] => null,
      ['on'] => true,
      ['off'] => false,
      _ => throw UsageException('Pass on, off or nothing.', usage),
    };
  }

  @override
  Future<int> runWithConnection(FlameConnection connection) async {
    final componentId = argResults!.option('component');
    final target = componentId == null
        ? 'the game'
        : 'the component $componentId';
    final enable = _enable;
    if (enable == null) {
      final response = await connection.call(
        'getDebugMode',
        args: {if (componentId != null) 'id': componentId},
      );
      final enabled = response['debug_mode'] == true;
      out.writeln('Debug mode is ${enabled ? 'on' : 'off'} for $target.');
      return ExitCodes.success;
    }

    await connection.call(
      'setDebugMode',
      args: {
        'debug_mode': enable.toString(),
        if (componentId != null) 'id': componentId,
      },
    );
    out.writeln('Turned debug mode ${enable ? 'on' : 'off'} for $target.');
    return ExitCodes.success;
  }
}
