import 'dart:math';

import 'package:jenny/src/command_storage.dart';
import 'package:jenny/src/errors.dart';
import 'package:jenny/src/function_storage.dart';
import 'package:jenny/src/localization.dart';
import 'package:jenny/src/parse/parse.dart' as impl;
import 'package:jenny/src/structure/node.dart';
import 'package:jenny/src/variable_storage.dart';
import 'package:meta/meta.dart';

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
        functions = FunctionStorage(),
        commands = CommandStorage(),
        random = Random() {
    locale = 'en';
  }

  late String _locale;

  /// All parsed [Node]s, keyed by their titles.
  final Map<String, Node> nodes;

  final VariableStorage variables;

  /// User-defined functions are stored here.
  final FunctionStorage functions;

  /// Repository for user-defined commands.
  final CommandStorage commands;

  /// Random number generator used by the dialogue whenever randomization is
  /// needed.
  Random random;

  /// Locale (language) used in this YarnProject.
  ///
  /// The default locale is 'en' (English), but you can select a different
  /// locale after a YarnProject is created.
  ///
  /// If you need a locale that is not currently supported by Jenny, you can add
  /// the corresponding entry into the `localizationInfo` map.
  String get locale => _locale;
  set locale(String value) {
    final entry = localizationInfo[value];
    if (entry == null) {
      throw DialogueError('Unknown locale "$value"');
    }
    if (nodes.isNotEmpty) {
      throw DialogueError(
        'The locale cannot be changed after nodes have been added',
      );
    }
    localization = entry;
    _locale = value;
  }

  /// Settings related to localization.
  @internal
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
}
