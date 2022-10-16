
import 'package:flame_yarn/src/structure/expressions/expression.dart';
import 'package:flame_yarn/src/structure/statement.dart';

class Dialogue extends Statement {
  const Dialogue({
    this.speaker,
    required this.content,
    this.tags,
  });

  final String? speaker;
  final StringExpression content;
  final List<String>? tags;
}
