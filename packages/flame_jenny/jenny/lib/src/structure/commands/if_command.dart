import 'package:jenny/src/dialogue_runner.dart';
import 'package:jenny/src/structure/block.dart';
import 'package:jenny/src/structure/commands/command.dart';
import 'package:jenny/src/structure/expressions/expression.dart';

class IfCommand extends Command {
  const IfCommand(this.ifs);

  /// First entry here is the <<if>> command, subsequent entries are the
  /// <<elseif>> commands, and the last entry is the <<else>> block (if
  /// present), which is represented as an [IfBlock] with `condition =
  /// constTrue`.
  final List<IfBlock> ifs;

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

class IfBlock {
  const IfBlock(this.condition, this.block);

  final BoolExpression condition;
  final Block block;
}
