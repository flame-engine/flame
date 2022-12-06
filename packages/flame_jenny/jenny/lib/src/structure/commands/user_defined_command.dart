import 'dart:async';

import 'package:jenny/src/dialogue_runner.dart';
import 'package:jenny/src/structure/commands/command.dart';
import 'package:jenny/src/structure/line_content.dart';

class UserDefinedCommand extends Command {
  UserDefinedCommand(this.name, this.argumentString);

  @override
  final String name;
  final LineContent argumentString;

  @override
  FutureOr<void> execute(DialogueRunner dialogue) {
    return dialogue.project.commands
        .runCommand(name, argumentString.evaluate());
  }

  @override
  String toString() => 'Command($name)';
}
