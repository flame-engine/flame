
import 'package:flame/src/text/nodes/block_node.dart';

class GroupBlockNode extends BlockNode {
  GroupBlockNode(this.children);

  final List<BlockNode> children;
}
