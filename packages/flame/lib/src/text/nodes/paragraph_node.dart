import 'package:flame/src/text/nodes/plain_text_node.dart';
import 'package:flame/src/text/nodes/text_block_node.dart';
import 'package:flame/src/text/styles/block_style.dart';
import 'package:flame/src/text/styles/document_style.dart';
import 'package:flame/src/text/styles/style.dart';
import 'package:flame/src/text/styles/text_style.dart';
import 'package:flutter/rendering.dart' show EdgeInsets;

class ParagraphNode extends TextBlockNode {
  ParagraphNode.simple(String text)
      : super(PlainTextNode(text));

  static const defaultStyle = BlockStyle(
    margin: EdgeInsets.all(6),
  );

  @override
  void fillStyles(DocumentStyle stylesheet, TextStyle parentTextStyle) {
    style = stylesheet.paragraph;
    final textStyle = Style.merge(parentTextStyle, style.text)!;
    super.fillStyles(stylesheet, textStyle);
  }
}
