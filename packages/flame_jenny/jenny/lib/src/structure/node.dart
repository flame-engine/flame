import 'package:jenny/jenny.dart';
import 'package:jenny/src/structure/block.dart';
import 'package:jenny/src/structure/dialogue_entry.dart';

class Node extends Iterable<DialogueEntry> {
  const Node({
    required this.title,
    required this.content,
    this.tags,
    this.variables,
  });

  final String title;
  final Map<String, String>? tags;
  final Block content;
  final VariableStorage? variables;

  List<DialogueEntry> get lines => content.lines;

  @override
  String toString() => 'Node($title)';

  @override
  NodeIterator get iterator => NodeIterator(this);
}

class NodeIterator implements Iterator<DialogueEntry> {
  NodeIterator(this.node) {
    diveInto(node.content);
  }

  final Node node;
  final List<Block> blocks = [];
  final List<int> multiIndex = [];

  @override
  DialogueEntry get current => blocks.last.lines[multiIndex.last];

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
