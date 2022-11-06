import 'package:jenny/src/dialogue_runner.dart';
import 'package:jenny/src/structure/commands/command.dart';
import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/yarn_project.dart';

class DeclareCommand extends Command {
  const DeclareCommand(this.variable, this.expression);

  final String variable;
  final Expression expression;

  @override
  String get name => 'declare';

  void executeInProject(YarnProject project) {
    project.variables.setVariable(variable, expression.value);
  }

  @override
  void execute(DialogueRunner dialogue) {
    dialogue.project.variables.setVariable(variable, expression.value);
  }
}
