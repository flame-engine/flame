import 'package:args/command_runner.dart';
import 'package:flame_cli/src/command_categories.dart';
import 'package:flame_cli/src/commands/flame_command.dart';
import 'package:flame_cli/src/component_tree.dart';
import 'package:flame_cli/src/exit_codes.dart';
import 'package:flame_cli/src/flame_connection.dart';
import 'package:flame_cli/src/json_output.dart';

/// Prints the component tree of the game, with the id and the attributes of
/// every component.
class TreeCommand extends FlameCommand {
  TreeCommand(super.out, super.workingDirectory) {
    argParser
      ..addOption(
        'filter',
        abbr: 'f',
        help:
            'Only show the components whose type matches this regular '
            'expression (case insensitive), together with their ancestors '
            'and children.',
      )
      ..addOption(
        'depth',
        abbr: 'd',
        help: 'The number of levels below the game to show.',
      )
      ..addFlag(
        'json',
        negatable: false,
        help: 'Print the tree as JSON instead of text.',
      );
  }

  @override
  String get name => 'tree';

  @override
  String get category => CommandCategories.observing;

  @override
  String get description =>
      'Print the component tree of the game with the id and the attributes '
      'of every component.';

  late int? _maxDepth;
  late RegExp? _filter;

  @override
  void validate() {
    final depth = argResults!.option('depth');
    _maxDepth = depth == null ? null : int.tryParse(depth);
    if (depth != null && (_maxDepth == null || _maxDepth! < 0)) {
      throw UsageException('--depth has to be a non-negative integer.', usage);
    }

    final filter = argResults!.option('filter');
    try {
      _filter = filter == null ? null : RegExp(filter, caseSensitive: false);
    } on FormatException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        UsageException(
          '--filter is not a valid regular expression: ${error.message}',
          usage,
        ),
        stackTrace,
      );
    }
  }

  @override
  Future<int> runWithConnection(FlameConnection connection) async {
    final response = await connection.call('getComponentTree');
    var tree = response['component_tree'] as Map<String, dynamic>?;

    final filter = _filter;
    if (tree != null && filter != null) {
      tree = filterComponentTree(
        tree,
        (node) => filter.hasMatch(node['name'] as String),
      );
    }
    if (tree == null) {
      out.writeln(argResults!.flag('json') ? 'null' : 'No components match.');
      return ExitCodes.success;
    }

    if (argResults!.flag('json')) {
      out.writeln(toJsonOutput(tree));
    } else {
      out.write(formatComponentTree(tree, maxDepth: _maxDepth));
    }
    return ExitCodes.success;
  }
}
