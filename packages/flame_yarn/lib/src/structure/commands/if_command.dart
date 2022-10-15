import 'package:flame_yarn/src/structure/commands/command.dart';
import 'package:flame_yarn/src/structure/expressions/expression.dart';
import 'package:flame_yarn/src/structure/statement.dart';
import 'package:flame_yarn/src/yarn_ball.dart';

class IfCommand extends Command {
  const IfCommand(this.ifs);

  final List<IfBlock> ifs;

  @override
  void execute(YarnBall runtime) {
    for (final block in ifs) {
      if (block.condition.value) {
        // runtime.executeEntries(block.entries);
        break;
      }
    }
  }
}

class IfBlock {
  const IfBlock(this.condition, this.entries);

  final TypedExpression<bool> condition;
  final List<Statement> entries;
}
