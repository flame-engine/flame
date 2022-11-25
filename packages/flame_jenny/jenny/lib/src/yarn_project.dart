import 'dart:math';

import 'package:jenny/src/command_storage.dart';
import 'package:jenny/src/errors.dart';
import 'package:jenny/src/localization.dart';
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
        commands = CommandStorage(),
        random = Random() {
    setUpPluralFunctionForLocale('en');
  }

  /// All parsed [Node]s, keyed by their titles.
  final Map<String, Node> nodes;

  final VariableStorage variables;

  /// Repository for user-defined commands.
  final CommandStorage commands;

  /// Random number generator used by the dialogue whenever randomization is
  /// needed.
  Random random;

  /// Settings related to localization.
  late Localization localization;

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

  void setUpPluralFunctionForLocale(String locale) {
    final entry = localizationInfo[locale];
    if (entry == null) {
      throw DialogueError(
        'Unknown locale "$locale". Add the corresponding plural() function '
        'into the `localizationInfo` map',
      );
    }
    localization = entry;
  }
}
