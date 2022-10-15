
import 'package:flame_yarn/src/structure/expressions/expression.dart';
import 'package:flame_yarn/src/structure/statement.dart';

class Line extends Statement {
  const Line({
    this.speaker,
    required this.content,
    this.condition,
    this.tags,
  });

  final String? speaker;
  final TypedExpression<String> content;
  final TypedExpression<bool>? condition;
  final List<String>? tags;
}
