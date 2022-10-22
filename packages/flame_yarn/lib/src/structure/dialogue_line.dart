import 'package:flame_yarn/src/structure/expressions/expression.dart';
import 'package:flame_yarn/src/structure/statement.dart';

class DialogueLine extends Statement {
  const DialogueLine({
    this.person,
    required this.content,
    this.tags,
  });

  final String? person;
  final StringExpression content;
  final List<String>? tags;

  @override
  StatementKind get kind => StatementKind.line;
}
