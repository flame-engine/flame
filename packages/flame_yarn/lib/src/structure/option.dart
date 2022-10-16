
import 'package:flame_yarn/src/structure/expressions/expression.dart';
import 'package:flame_yarn/src/structure/statement.dart';

class Option extends Statement {
  Option({
    required this.content,
    this.condition,
    this.tags,
    this.continuation = const <Statement>[],
  });

  final StringExpression content;
  final BoolExpression? condition;
  final List<String>? tags;
  final List<Statement> continuation;
  bool available = true;
}
