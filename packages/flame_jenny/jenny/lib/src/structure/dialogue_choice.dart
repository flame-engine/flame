import 'package:jenny/src/structure/option.dart';
import 'package:jenny/src/structure/statement.dart';

class DialogueChoice extends Statement {
  const DialogueChoice(this.options);

  final List<Option> options;

  @override
  StatementKind get kind => StatementKind.choice;

  @override
  String toString() => 'DialogueChoice($options)';
}
