import 'package:meta/meta.dart';
import 'package:throstle/src/parse/parse.dart' as impl;
import 'package:throstle/src/structure/node.dart';
import 'package:throstle/src/variable_storage.dart';

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
