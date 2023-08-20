import 'package:flame/src/text/elements/text_element.dart';
import 'package:flame/src/text/styles/document_style.dart';
import 'package:flame/src/text/styles/flame_text_style.dart';

/// [TextNode] is a base class for all nodes with "inline" placement rules; it
/// roughly corresponds to `<span/>` in HTML.
///
/// Implementations include:
/// * PlainTextNode - just a string of plain text, no special formatting.
/// * BoldTextNode - bolded string
/// * ItalicTextNode - italic string
/// * GroupTextNode - collection of multiple [TextNode]'s to be joined one
///                   after the other.
abstract class TextNode {
  late FlameTextStyle textStyle;

  void fillStyles(DocumentStyle stylesheet, FlameTextStyle parentTextStyle);

  TextNodeLayoutBuilder get layoutBuilder;
}

abstract class TextNodeLayoutBuilder {
  TextElement? layOutNextLine(double availableWidth);
  bool get isDone;
}
