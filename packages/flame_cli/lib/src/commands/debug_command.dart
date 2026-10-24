import 'package:args/command_runner.dart';
import 'package:flame_cli/src/command_categories.dart';
import 'package:flame_cli/src/commands/flame_command.dart';
import 'package:flame_cli/src/commands/inspect_command.dart';
import 'package:flame_cli/src/flame_connection.dart';
import 'package:io/io.dart';

/// Shows or changes the debug mode of the game, or of a single component.
class DebugCommand(super.out, super.workingDirectory) extends FlameCommand {
  this {
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
  int? _componentId;

  @override
  void validate() {
    _componentId = componentIdOption(this, 'component');
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
    final componentId = _componentId;
    final target = componentId == null
        ? 'the game'
        : 'the component $componentId';
    final enable = _enable;
    if (enable == null) {
      final enabled = await connection.getDebugMode(id: componentId);
      writeResult(
        {'debugMode': enabled, 'component': componentId},
        'Debug mode is ${enabled ? 'on' : 'off'} for $target.',
      );
      return ExitCode.success.code;
    }

    await connection.setDebugMode(debugMode: enable, id: componentId);
    writeResult(
      {'debugMode': enable, 'component': componentId},
      'Turned debug mode ${enable ? 'on' : 'off'} for $target.',
    );
    return ExitCode.success.code;
  }
}
