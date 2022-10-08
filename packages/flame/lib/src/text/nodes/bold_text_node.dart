import 'dart:ui';

import 'package:flame/src/text/nodes/group_text_node.dart';
import 'package:flame/src/text/nodes/plain_text_node.dart';
import 'package:flame/src/text/nodes/text_node.dart';
import 'package:flame/src/text/styles/document_style.dart';
import 'package:flame/src/text/styles/flame_text_style.dart';
import 'package:flame/src/text/styles/style.dart';

class BoldTextNode extends TextNode {
  BoldTextNode(this.child);

  BoldTextNode.simple(String text) : child = PlainTextNode(text);

  BoldTextNode.group(List<TextNode> children) : child = GroupTextNode(children);

  final TextNode child;

  static final defaultStyle = FlameTextStyle(fontWeight: FontWeight.bold);

  @override
  void fillStyles(DocumentStyle stylesheet, FlameTextStyle parentTextStyle) {
    textStyle = Style.merge(parentTextStyle, stylesheet.boldText)!;
    child.fillStyles(stylesheet, textStyle);
  }

  @override
  TextNodeLayoutBuilder get layoutBuilder => child.layoutBuilder;
}
