import 'package:jenny/src/structure/expressions/expression.dart';

// TODO(st-pasha): visited(String nodeName)
// TODO(st-pasha): visited_count(String nodeName)

/// Function `bool(num x)`.
class NumToBoolFn extends BoolExpression {
  const NumToBoolFn(this.arg);

  final NumExpression arg;

  @override
  bool get value => arg.value != 0;
}
