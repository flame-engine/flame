import 'package:jenny/src/dialogue_runner.dart';
import 'package:jenny/src/structure/commands/command.dart';
import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/variable_storage.dart';

class const LocalCommand(
  final String variable,
  final Expression expression,
  final VariableStorage storage,
) extends Command {
  @override
  String get name => 'local';

  @override
  void execute(DialogueRunner dialogue) {
    storage.setVariable(variable, expression.value);
  }
}
