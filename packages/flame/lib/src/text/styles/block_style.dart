
import 'package:flame/src/text/block/block_element.dart';
import 'package:flame/src/text/nodes.dart';

class BlockStyle {
  BlockElement format(BlockNode node) {
    return BlockElement(node, this);
  }
}
