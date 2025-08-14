import 'package:flame/text.dart';
import 'package:flutter/rendering.dart' show EdgeInsets;

class ParagraphNode extends TextBlockNode {
  ParagraphNode(super.child);

  ParagraphNode.simple(String text) : super(PlainTextNode(text));

  ParagraphNode.group(List<InlineTextNode> fragments)
    : super(GroupTextNode(fragments));

  static const defaultStyle = BlockStyle(
    margin: EdgeInsets.all(6),
  );

  @override
  void fillStyles(DocumentStyle stylesheet, InlineTextStyle parentTextStyle) {
    style = stylesheet.paragraph;
    final textStyle = FlameTextStyle.merge(parentTextStyle, style.text)!;
    super.fillStyles(stylesheet, textStyle);
  }
}
