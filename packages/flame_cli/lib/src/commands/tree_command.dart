import 'package:flame_cli/src/commands/flame_command.dart';
import 'package:flame_cli/src/component_tree.dart';
import 'package:flame_cli/src/exit_codes.dart';
import 'package:flame_cli/src/flame_connection.dart';

/// Prints the component tree of the game, with the id of every component.
class TreeCommand extends FlameCommand {
  TreeCommand(super.out, super.workingDirectory);

  @override
  String get name => 'tree';

  @override
  String get description =>
      'Print the component tree of the game with the id of every component.';

  @override
  Future<int> runWithConnection(FlameConnection connection) async {
    final response = await connection.call('getComponentTree');
    final tree = response['component_tree'] as Map<String, dynamic>;
    out.write(formatComponentTree(tree));
    return ExitCodes.success;
  }
}
