
import 'package:flame_yarn/src/structure/statement.dart';

class Block {
  const Block(this.lines);
  const Block.empty() : lines = const [];

  final List<Statement> lines;

  int get length => lines.length;
  bool get isEmpty => lines.isEmpty;
  bool get isNotEmpty => lines.isNotEmpty;
}
