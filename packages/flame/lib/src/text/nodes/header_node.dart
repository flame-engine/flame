import 'package:flame/src/text/nodes.dart';
import 'package:flame/src/text/nodes/block_node.dart';

class HeaderNode extends BlockNode {
  HeaderNode(this.child, {required this.level});

  final GroupTextNode child;
  final int level;
}
