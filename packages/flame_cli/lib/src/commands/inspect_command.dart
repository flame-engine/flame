import 'package:args/command_runner.dart';
import 'package:flame_cli/src/command_categories.dart';
import 'package:flame_cli/src/commands/flame_command.dart';
import 'package:flame_cli/src/flame_connection.dart';
import 'package:flame_cli/src/game_responses.dart';
import 'package:flame_cli/src/json_output.dart';
import 'package:io/io.dart';

/// Prints information about a single component.
class InspectCommand(super.out, super.workingDirectory) extends FlameCommand {
  this {
    argParser.addFlag(
      'json',
      negatable: false,
      help: 'Print the information as JSON instead of text.',
    );
  }

  @override
  String get name => 'inspect';

  @override
  String get category => CommandCategories.observing;

  @override
  String get description =>
      'Print the type, attributes and other details of a component.';

  @override
  String get invocation => 'flame inspect <component id>';

  late int _id;

  @override
  void validate() {
    _id = componentIdArgument(this);
  }

  @override
  Future<int> runWithConnection(FlameConnection connection) async {
    final info = await connection.getComponentInfo(_id);
    if (argResults!.flag('json')) {
      out.writeln(toJsonOutput(info.toJson()));
      return ExitCode.success.code;
    }

    out.write(formatComponentInfo(info));
    return ExitCode.success.code;
  }
}

/// Reads the single component id argument of a command.
int componentIdArgument(Command<int> command) {
  final rest = command.argResults!.rest;
  final id = rest.length == 1 ? int.tryParse(rest.single) : null;
  if (id == null) {
    throw UsageException(
      'Pass the id of one component, use the tree command to list the ids.',
      command.usage,
    );
  }
  return id;
}

/// Reads the [option] of a command that holds the id of a component.
///
/// Returns null when the option is not given.
int? componentIdOption(Command<int> command, String option) {
  final value = command.argResults!.option(option);
  if (value == null) {
    return null;
  }
  final id = int.tryParse(value);
  if (id == null) {
    throw UsageException(
      '--$option has to be the id of a component, use the tree command to '
      'list the ids.',
      command.usage,
    );
  }
  return id;
}

/// Formats the details of a component with one line per field.
String formatComponentInfo(ComponentInfo info) {
  final attributes = info.attributes;
  final buffer = StringBuffer()
    ..writeln('type: ${info.name}')
    ..writeln('id: ${info.id}')
    ..writeln('parent: ${info.parent ?? 'none'}')
    ..writeln('children: ${info.childCount}')
    ..writeln('debugMode: ${info.debugMode}');
  void writeVector(String name, Vector2? vector) {
    if (vector != null) {
      buffer.writeln('$name: ${vector.x}, ${vector.y}');
    }
  }

  if (attributes.priority case final priority?) {
    buffer.writeln('priority: $priority');
  }
  writeVector('position', attributes.position);
  writeVector('size', attributes.size);
  if (attributes.angle case final angle?) {
    buffer.writeln('angle: $angle');
  }
  writeVector('scale', attributes.scale);
  if (attributes.anchor case final anchor?) {
    buffer.writeln('anchor: $anchor');
  }
  buffer.writeln('toString: ${info.toStringText}');
  return buffer.toString();
}
