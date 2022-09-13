import 'package:flame/src/text/nodes/block_node.dart';
import 'package:flame/src/text/nodes/text_nodes.dart';
import 'package:flame/src/text/styles/block_style.dart';
import 'package:flame/src/text/styles/document_style.dart';
import 'package:flame/src/text/styles/style.dart';
import 'package:flame/src/text/styles/text_style.dart';
import 'package:flutter/rendering.dart' show EdgeInsets;

class ParagraphNode extends BlockNode {
  ParagraphNode.simple(String text)
      : super(GroupTextNode([PlainTextNode(text)]));

  static const defaultStyle = BlockStyle(
    margin: EdgeInsets.all(6),
  );

  @override
  void fillStyles(DocumentStyle stylesheet, TextStyle parentTextStyle) {
    style = stylesheet.paragraph;
    textStyle = Style.merge(parentTextStyle, style.text)!;
  }
}
