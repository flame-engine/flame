import 'package:jenny/src/dialogue_runner.dart';
import 'package:jenny/src/structure/commands/command.dart';
import 'package:jenny/src/structure/expressions/expression.dart';

class VisitCommand extends Command {
  VisitCommand(this.target);

  final StringExpression target;

  @override
  Future<void> execute(DialogueRunner dialogue) {
    return dialogue.visitNode(target.value);
  }

  @override
  String get name => 'visit';
}
