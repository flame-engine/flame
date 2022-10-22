import 'package:flame_yarn/src/structure/block.dart';
import 'package:flame_yarn/src/structure/expressions/expression.dart';

class Option {
  Option({
    required this.content,
    this.person,
    this.condition,
    this.tags,
    this.block = const Block([]),
  });

  final String? person;
  final StringExpression content;
  final List<String>? tags;
  final BoolExpression? condition;
  final Block block;
  bool available = true;
}
