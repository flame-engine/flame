import 'package:flame/text.dart';

/// [InlineTextNode] is a base class for all nodes with "inline" placement
/// rules; it roughly corresponds to `<span/>` in HTML.
///
/// Implementations include:
/// * PlainTextNode - just a string of plain text, no special formatting.
/// * BoldTextNode - bolded string
/// * ItalicTextNode - italic string
/// * CodeTextNode - inline code block
/// * GroupTextNode - collection of multiple [InlineTextNode]'s to be joined one
///                   after the other.
abstract class InlineTextNode extends TextNode<InlineTextStyle> {
  @override
  late InlineTextStyle style;

  @override
  void fillStyles(DocumentStyle stylesheet, InlineTextStyle parentTextStyle);

  TextNodeLayoutBuilder get layoutBuilder;
}

abstract class TextNodeLayoutBuilder {
  InlineTextElement? layOutNextLine(double availableWidth);
  bool get isDone;
}
