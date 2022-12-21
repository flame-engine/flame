import 'dart:async';

import 'package:jenny/src/dialogue_runner.dart';
import 'package:jenny/src/structure/commands/command.dart';
import 'package:jenny/src/structure/line_content.dart';
import 'package:meta/meta.dart';

class UserDefinedCommand extends Command {
  UserDefinedCommand(this.name, this._content);

  @override
  final String name;
  final LineContent _content;
  late String _argumentString;
  late List<dynamic>? _arguments;

  /// The arguments to this command, as a single non-parsed string.
  String get argumentString => _argumentString;

  /// Parsed arguments, as a list. This may be `null` if a command was declared
  /// without a signature (i.e. as a "dialogue command").
  List<dynamic>? get arguments => _arguments;

  @override
  FutureOr<void> execute(DialogueRunner dialogue) {
    return dialogue.project.commands.runCommand(this);
  }

  @override
  String toString() => 'Command($name)';

  @internal
  LineContent get content => _content;

  @internal
  set argumentString(String value) => _argumentString = value;

  @internal
  set arguments(List<dynamic>? value) => _arguments = value;
}
