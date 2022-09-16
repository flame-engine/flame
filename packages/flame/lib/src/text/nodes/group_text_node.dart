
import 'package:flame/src/text/nodes/text_node.dart';

class GroupTextNode extends TextNode {
  GroupTextNode(this.children);

  final List<TextNode> children;
}
