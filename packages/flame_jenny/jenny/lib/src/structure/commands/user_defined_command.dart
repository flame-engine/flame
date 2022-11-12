import 'dart:async';

import 'package:jenny/src/dialogue_runner.dart';
import 'package:jenny/src/structure/commands/command.dart';
import 'package:jenny/src/structure/expressions/expression.dart';

class UserDefinedCommand extends Command {
  UserDefinedCommand(this.name, this.argumentString);

  @override
  final String name;
  final StringExpression argumentString;

  @override
  FutureOr<void> execute(DialogueRunner dialogue) {
    return dialogue.project.commands.runCommand(name, argumentString.value);
  }
}
