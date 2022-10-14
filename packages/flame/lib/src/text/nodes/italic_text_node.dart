import 'dart:ui';

import 'package:flame/src/text/nodes/group_text_node.dart';
import 'package:flame/src/text/nodes/plain_text_node.dart';
import 'package:flame/src/text/nodes/text_node.dart';
import 'package:flame/src/text/styles/document_style.dart';
import 'package:flame/src/text/styles/flame_text_style.dart';
import 'package:flame/src/text/styles/style.dart';

class ItalicTextNode extends TextNode {
  ItalicTextNode(this.child);

  ItalicTextNode.simple(String text) : child = PlainTextNode(text);

  ItalicTextNode.group(List<TextNode> children)
      : child = GroupTextNode(children);

  final TextNode child;

  static final defaultStyle = FlameTextStyle(fontStyle: FontStyle.italic);

  @override
  void fillStyles(DocumentStyle stylesheet, FlameTextStyle parentTextStyle) {
    textStyle = Style.merge(parentTextStyle, stylesheet.italicText)!;
    child.fillStyles(stylesheet, textStyle);
  }

  @override
  TextNodeLayoutBuilder get layoutBuilder => child.layoutBuilder;
}
