import 'package:jenny/src/command_storage.dart';
import 'package:jenny/src/parse/parse.dart' as impl;
import 'package:jenny/src/structure/node.dart';
import 'package:jenny/src/variable_storage.dart';

/// [YarnProject] is a central place where all dialogue-related information
/// is held:
/// - [nodes]: the map of nodes parsed from yarn files;
/// - [variables]: the repository of all global variables accessible to yarn
///                scripts;
/// - [functions]: user-defined functions;
/// - [commands]: user-defined commands;
///
class YarnProject {
  YarnProject()
      : nodes = <String, Node>{},
        variables = VariableStorage(),
        commands = CommandStorage();

  /// All parsed [Node]s, keyed by their titles.
  final Map<String, Node> nodes;

  final VariableStorage variables;

  final CommandStorage commands;

  /// Parses a single yarn file, given as a [text] string.
  ///
  /// This method may be called multiple times, in order to load as many yarn
  /// scripts as necessary.
  void parse(String text) {
    impl.parse(text, this);
  }

  void setVariable(String name, dynamic value) {
    variables.setVariable(name, value);
  }
}
