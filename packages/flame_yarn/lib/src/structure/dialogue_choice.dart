
import 'package:flame_yarn/src/structure/option.dart';
import 'package:flame_yarn/src/structure/statement.dart';

class DialogueChoice extends Statement {
  DialogueChoice(this.options);

  final List<Option> options;

  @override
  StatementKind get kind => StatementKind.choice;
}
