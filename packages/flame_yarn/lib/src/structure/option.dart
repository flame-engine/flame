
import 'package:flame_yarn/src/structure/expressions/expression.dart';
import 'package:flame_yarn/src/structure/statement.dart';

class Option extends Statement {
  Option({
    required this.content,
    this.speaker,
    this.condition,
    this.tags,
    this.block = const <Statement>[],
  });

  final String? speaker;
  final StringExpression content;
  final List<String>? tags;
  final BoolExpression? condition;
  final List<Statement> block;
  bool available = true;
}
