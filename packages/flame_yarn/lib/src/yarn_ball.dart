
import 'package:flame_yarn/src/parse/parser.dart' as internal;
import 'package:flame_yarn/src/structure/node.dart';
import 'package:flame_yarn/src/variable_storage.dart';

class YarnBall {
  YarnBall()
      : nodes = <String, Node>{},
        variables = VariableStorage();

  /// All parsed [Node]s, keyed by their titles.
  final Map<String, Node> nodes;

  final VariableStorage variables;

  void parse(String text) {
    internal.parse(text, this);
  }
}
