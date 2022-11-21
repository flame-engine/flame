import 'package:jenny/src/structure/block.dart';
import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/line_content.dart';

class Option {
  Option({
    required this.content,
    this.character,
    this.condition,
    this.tags,
    this.block = const Block([]),
  });

  final String? character;
  final LineContent content;
  final List<String>? tags;
  final BoolExpression? condition;
  final Block block;
  bool available = true;

  String get value => content.evaluate();

  @override
  String toString() {
    final prefix = character == null ? '' : '$character: ';
    final suffix = available ? '' : ' #disabled';
    return 'Option($prefix$value$suffix)';
  }
}
