import 'package:jenny/src/structure/block.dart';
import 'package:jenny/src/structure/dialogue_line.dart';
import 'package:jenny/src/structure/expressions/expression.dart';

class DialogueOption extends DialogueLine {
  DialogueOption({
    required super.content,
    super.character,
    super.tags,
    BoolExpression? condition,
    this.block = const Block([]),
  }) : _condition = condition;

  final BoolExpression? _condition;
  final Block block;
  bool _available = true;

  bool get isAvailable => _available;
  bool get isDisabled => !_available;

  @override
  void evaluate() {
    super.evaluate();
    _available = _condition?.value ?? true;
  }

  @override
  String toString() {
    final prefix = character == null ? '' : '$character: ';
    final suffix = _available ? '' : ' #disabled';
    return 'Option($prefix$text$suffix)';
  }
}
