import 'package:flame_yarn/src/structure/block.dart';
import 'package:flame_yarn/src/structure/expressions/expression.dart';

class Option {
  Option({
    required this.content,
    this.character,
    this.condition,
    this.tags,
    this.block = const Block([]),
  });

  final String? character;
  final StringExpression content;
  final List<String>? tags;
  final BoolExpression? condition;
  final Block block;
  bool available = true;

  @override
  String toString() {
    final prefix = character == null ? '' : '$character: ';
    final suffix = available ? '' : ' #disabled';
    return 'Option($prefix${content.value}$suffix)';
  }
}
