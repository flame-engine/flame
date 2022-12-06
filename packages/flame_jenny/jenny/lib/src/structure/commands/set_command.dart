import 'package:jenny/src/dialogue_runner.dart';
import 'package:jenny/src/structure/commands/command.dart';
import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/variable_storage.dart';

class SetCommand extends Command {
  const SetCommand(this.variable, this.expression, this.storage);

  final String variable;
  final Expression expression;
  final VariableStorage storage;

  @override
  String get name => 'set';

  @override
  void execute(DialogueRunner dialogue) {
    storage.setVariable(variable, expression.value);
  }
}
