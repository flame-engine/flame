import 'package:flame/src/text/nodes/inline_text_node.dart';
import 'package:flame/text.dart';

/// An [InlineTextNode] representing a span of text with a custom style applied.
class CustomInlineTextNode extends InlineTextNode {
  final String styleName;

  CustomInlineTextNode(this.child, {required this.styleName});

  CustomInlineTextNode.simple(String text, {required this.styleName})
    : child = PlainTextNode(text);

  final InlineTextNode child;

  @override
  void fillStyles(DocumentStyle stylesheet, InlineTextStyle parentTextStyle) {
    style =
        FlameTextStyle.merge(
          parentTextStyle,
          stylesheet.getCustomStyle(styleName),
        ) ??
        stylesheet.text;
    child.fillStyles(stylesheet, style);
  }

  @override
  TextNodeLayoutBuilder get layoutBuilder => child.layoutBuilder;
}
