import 'package:args/command_runner.dart';
import 'package:flame_cli/src/commands/flame_command.dart';
import 'package:flame_cli/src/exit_codes.dart';
import 'package:flame_cli/src/flame_connection.dart';
import 'package:flame_cli/src/json_output.dart';

/// Prints information about a single component.
class InspectCommand extends FlameCommand {
  InspectCommand(super.out, super.workingDirectory) {
    argParser.addFlag(
      'json',
      negatable: false,
      help: 'Print the information as JSON instead of text.',
    );
  }

  @override
  String get name => 'inspect';

  @override
  String get description =>
      'Print the type, attributes and other details of a component.';

  @override
  String get invocation => 'flame inspect <component id>';

  late String _id;

  @override
  void validate() {
    _id = componentIdArgument(this);
  }

  @override
  Future<int> runWithConnection(FlameConnection connection) async {
    final info = await connection.call('getComponentInfo', args: {'id': _id});
    if (argResults!.flag('json')) {
      out.writeln(toJsonOutput(info));
      return ExitCodes.success;
    }

    out.write(formatComponentInfo(info));
    return ExitCodes.success;
  }
}

/// Reads the single component id argument of a command.
String componentIdArgument(Command<int> command) {
  final rest = command.argResults!.rest;
  if (rest.length != 1 || int.tryParse(rest.single) == null) {
    throw UsageException(
      'Pass the id of one component, use the tree command to list the ids.',
      command.usage,
    );
  }
  return rest.single;
}

/// Formats the response of the `getComponentInfo` service extension with one
/// line per field.
String formatComponentInfo(Map<String, dynamic> info) {
  final attributes = (info['attributes'] as Map<String, dynamic>?) ?? const {};
  final buffer = StringBuffer()
    ..writeln('type: ${info['name']}')
    ..writeln('id: ${info['id']}')
    ..writeln('parent: ${info['parent'] ?? 'none'}')
    ..writeln('children: ${info['childCount']}')
    ..writeln('debugMode: ${info['debugMode']}');
  for (final entry in attributes.entries) {
    final value = entry.value;
    buffer.writeln(
      '${entry.key}: ${value is List ? value.join(', ') : value}',
    );
  }
  buffer.writeln('toString: ${info['toString']}');
  return buffer.toString();
}
