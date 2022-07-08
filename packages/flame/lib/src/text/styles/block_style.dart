
import 'package:flame/src/text/elements/block_element.dart';
import 'package:flame/src/text/nodes.dart';
import 'package:flutter/painting.dart';

class BlockStyle {
  EdgeInsets margin = EdgeInsets.zero;
  EdgeInsets padding = EdgeInsets.zero;

  BlockElement format(BlockNode node, {required double parentWidth}) {
    return BlockElement(node, this);
  }
}
