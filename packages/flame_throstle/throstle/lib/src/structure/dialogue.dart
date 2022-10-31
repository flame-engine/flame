import 'package:throstle/src/structure/expressions/expression.dart';
import 'package:throstle/src/structure/statement.dart';

class Dialogue extends Statement {
  const Dialogue({
    this.person,
    required this.content,
    this.tags,
  });

  final String? person;
  final StringExpression content;
  final List<String>? tags;
}
