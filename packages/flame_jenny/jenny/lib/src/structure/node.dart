import 'package:jenny/jenny.dart';
import 'package:jenny/src/structure/block.dart';
import 'package:jenny/src/structure/dialogue_entry.dart';
import 'package:meta/meta.dart';

class Node extends Iterable<DialogueEntry> {
  const Node({
    required this.title,
    required Block content,
    Map<String, String>? tags,
    VariableStorage? variables,
  }) : _content = content,
       _tags = tags,
       _variables = variables;

  final String title;
  final Map<String, String>? _tags;
  final Block _content;
  final VariableStorage? _variables;

  /// The list of extra tags specified in the node header.
  Map<String, String> get tags => _tags ?? const <String, String>{};

  /// Local variable storage for this node. This can be `null` if the node does
  /// not define any local variables.
  VariableStorage? get variables => _variables;

  /// The iterator over the content of the node.
  @override
  NodeIterator get iterator => NodeIterator(this);

  @visibleForTesting
  List<DialogueEntry> get lines => _content.lines;

  @override
  String toString() => 'Node($title)';
}

class NodeIterator implements Iterator<DialogueEntry> {
  NodeIterator(this.node) {
    diveInto(node._content);
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
