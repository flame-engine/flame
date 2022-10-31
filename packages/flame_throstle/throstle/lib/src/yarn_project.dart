import 'package:flame_yarn/src/parse/parse.dart' as impl;
import 'package:flame_yarn/src/structure/node.dart';
import 'package:flame_yarn/src/variable_storage.dart';
import 'package:meta/meta.dart';

class YarnProject {
  YarnProject()
      : nodes = <String, Node>{},
        variables = VariableStorage();

  /// All parsed [Node]s, keyed by their titles.
  final Map<String, Node> nodes;

  final VariableStorage variables;

  void parse(String text) {
    impl.parse(text, this);
  }

  void setVariable(String name, dynamic value) {
    variables.setVariable(name, value);
  }

  @internal
  void jumpToNode(String node) {}

  @internal
  void stopNode() {}

  @internal
  void wait(num seconds) {}
}
