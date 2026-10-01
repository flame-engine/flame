import 'package:jenny/src/dialogue_runner.dart';
import 'package:jenny/src/structure/block.dart';
import 'package:jenny/src/structure/commands/command.dart';
import 'package:jenny/src/structure/expressions/expression.dart';

class const IfCommand(
  /// First entry here is the `<<if>>` command, subsequent entries are the
  /// `<<elseif>>` commands, and the last entry is the `<<else>>` block (if
  /// present), which is represented as an [IfBlock] with `condition =
  /// constTrue`.
  final List<IfBlock> ifs,
) extends Command {
  @override
  String get name => 'if';

  @override
  void execute(DialogueRunner dialogue) {
    for (final ifBlock in ifs) {
      if (ifBlock.condition.value) {
        dialogue.enterBlock(ifBlock.block);
        break;
      }
    }
  }
}

class const IfBlock(final BoolExpression condition, final Block block);
