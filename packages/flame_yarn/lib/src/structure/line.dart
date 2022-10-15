
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
  final Expression<String> content;
  final Expression<bool>? condition;
  final List<String>? tags;
}
