import 'package:jenny/src/structure/commands/command.dart';
import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/statement.dart';
import 'package:jenny/src/yarn_project.dart';

class IfCommand extends Command {
  const IfCommand(this.ifs);

  /// First entry here is the <<if>> command, subsequent entries are the
  /// <<elseif>> commands, and the last entry is the <<else>> block (if
  /// present), which is represented as an [IfBlock] with `condition =
  /// constTrue`.
  final List<IfBlock> ifs;

  @override
  void execute(YarnProject runtime) {
    for (final block in ifs) {
      if (block.condition.value) {
        // runtime.executeEntries(block.entries);
        break;
      }
    }
  }
}

class IfBlock {
  const IfBlock(this.condition, this.block);

  final BoolExpression condition;
  final List<Statement> block;
}
