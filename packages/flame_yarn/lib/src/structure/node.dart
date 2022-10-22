import 'package:flame_yarn/src/structure/block.dart';
import 'package:flame_yarn/src/structure/statement.dart';

class Node {
  Node({
    required this.title,
    required this.content,
    this.tags,
  });

  final String title;
  final Map<String, String>? tags;
  final Block content;

  List<Statement> get lines => content.lines;

  @override
  String toString() => 'Node($title)';

  NodeIterator get iterator => NodeIterator(this);
}

class NodeIterator implements Iterator<Statement> {
  NodeIterator(this.node) {
    diveInto(node.content);
  }

  final Node node;
  final List<Block> blocks = [];
  final List<int> multiIndex = [];

  @override
  Statement get current => blocks.last.lines[multiIndex.last];

  @override
  bool moveNext() {
    while (multiIndex.isNotEmpty) {
      final lastIndex = multiIndex.last;
      final lastBlock = blocks.last;
      if (lastIndex + 1 < lastBlock.length) {
        multiIndex.last += 1;
        return true;
      } else {
        multiIndex.removeLast();
        blocks.removeLast();
      }
    }
    return false;
  }

  void diveInto(Block block) {
    blocks.add(block);
    multiIndex.add(-1);
  }
}
