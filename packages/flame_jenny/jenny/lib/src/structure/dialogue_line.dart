import 'package:flame_yarn/src/structure/expressions/expression.dart';
import 'package:flame_yarn/src/structure/statement.dart';

class DialogueLine extends Statement {
  const DialogueLine({
    this.character,
    required this.content,
    this.tags,
  });

  final String? character;
  final StringExpression content;
  final List<String>? tags;

  @override
  StatementKind get kind => StatementKind.line;

  @override
  String toString() {
    final prefix = character == null ? '' : '$character: ';
    return 'DialogueLine($prefix${content.value})';
  }
}
