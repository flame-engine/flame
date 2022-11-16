import 'package:jenny/src/structure/dialogue_entry.dart';

class Block {
  const Block(this.lines);
  const Block.empty() : lines = const [];

  final List<DialogueEntry> lines;

  int get length => lines.length;
  bool get isEmpty => lines.isEmpty;
  bool get isNotEmpty => lines.isNotEmpty;
}
