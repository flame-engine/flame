import 'dart:ui';

import 'package:flame/src/text/nodes/group_text_node.dart';
import 'package:flame/src/text/nodes/plain_text_node.dart';
import 'package:flame/src/text/nodes/text_node.dart';
import 'package:flame/src/text/styles/document_style.dart';
import 'package:flame/src/text/styles/style.dart';
import 'package:flame/src/text/styles/text_style.dart';

class BoldTextNode extends TextNode {
  BoldTextNode(List<TextNode> children) : child = GroupTextNode(children);

  BoldTextNode.simple(String text) : child = PlainTextNode(text);

  final TextNode child;

  static final defaultStyle = TextStyle(fontWeight: FontWeight.bold);

  @override
  void fillStyles(DocumentStyle stylesheet, TextStyle parentTextStyle) {
    textStyle = Style.merge(parentTextStyle, stylesheet.boldText)!;
    child.fillStyles(stylesheet, textStyle);
  }

  @override
  TextNodeLayoutBuilder get layoutBuilder => child.layoutBuilder;
}
