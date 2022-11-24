import 'package:jenny/src/structure/block.dart';
import 'package:jenny/src/structure/dialogue_line.dart';
import 'package:jenny/src/structure/expressions/expression.dart';

class DialogueOption extends DialogueLine {
  DialogueOption({
    required super.content,
    super.character,
    super.tags,
    this.condition,
    this.block = const Block([]),
  });

  final BoolExpression? condition;
  final Block block;
  bool available = true;

  @override
  void evaluate() {
    super.evaluate();
    available = condition?.value ?? true;
  }

  @override
  String toString() {
    final prefix = character == null ? '' : '$character: ';
    final suffix = available ? '' : ' #disabled';
    return 'Option($prefix$text$suffix)';
  }
}
