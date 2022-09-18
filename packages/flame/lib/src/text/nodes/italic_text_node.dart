import 'dart:ui';

import 'package:flame/src/text/nodes/group_text_node.dart';
import 'package:flame/src/text/nodes/plain_text_node.dart';
import 'package:flame/src/text/nodes/text_node.dart';
import 'package:flame/src/text/styles/document_style.dart';
import 'package:flame/src/text/styles/style.dart';
import 'package:flame/src/text/styles/text_style.dart';

class ItalicTextNode extends TextNode {
  ItalicTextNode(this.child);

  ItalicTextNode.simple(String text) : child = PlainTextNode(text);

  ItalicTextNode.group(List<TextNode> children)
      : child = GroupTextNode(children);

  final TextNode child;

  static final defaultStyle = TextStyle(fontStyle: FontStyle.italic);

  @override
  void fillStyles(DocumentStyle stylesheet, TextStyle parentTextStyle) {
    textStyle = Style.merge(parentTextStyle, stylesheet.italicText)!;
    child.fillStyles(stylesheet, textStyle);
  }

  @override
  TextNodeLayoutBuilder get layoutBuilder => child.layoutBuilder;
}
