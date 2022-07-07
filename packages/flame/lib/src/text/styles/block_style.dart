
import 'package:flame/src/text/elements/block_element.dart';
import 'package:flame/src/text/nodes.dart';
import 'package:flutter/painting.dart';

class BlockStyle {
  EdgeInsets margin = EdgeInsets.zero;
  EdgeInsets padding = EdgeInsets.zero;

  BlockElement format(BlockNode node) {
    return BlockElement(node, this);
  }
}
