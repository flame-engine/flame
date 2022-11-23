import 'package:jenny/src/structure/expressions/expression.dart';

class MarkupAttribute {
  MarkupAttribute(
    this.name,
    this.startPosition,
    this.endPosition, [
    this.parameters,
  ])  : start = startPosition,
        end = endPosition;

  final String name;
  final int startPosition;
  final int endPosition;
  final Map<String, Expression>? parameters;
  int start;
  int end;
}
