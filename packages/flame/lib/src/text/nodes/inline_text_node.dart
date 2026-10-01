import 'package:flame/text.dart';
import 'package:flutter/painting.dart' show InlineSpan;

/// [InlineTextNode] is a base class for all nodes with "inline" placement
/// rules; it roughly corresponds to `<span/>` in HTML.
///
/// Implementations include:
/// * PlainTextNode - just a string of plain text, no special formatting.
/// * BoldTextNode - bolded string
/// * ItalicTextNode - italic string
/// * CodeTextNode - inline code string
/// * StrikethroughTextNode - strikethrough string
/// * CustomTextNode - applies arbitrary attributes to a span of text
/// * GroupTextNode - collection of multiple [InlineTextNode]'s to be joined one
///                   after the other.
abstract class InlineTextNode extends TextNode<InlineTextStyle> {
  @override
  late InlineTextStyle style;

  @override
  void fillStyles(DocumentStyle stylesheet, InlineTextStyle parentTextStyle);

  /// Converts this node into a Flutter [InlineSpan] carrying its resolved
  /// [style], so that a whole block of inline nodes can be laid out by
  /// Flutter's paragraph engine.
  ///
  /// [fillStyles] must have been called before this method.
  InlineSpan toInlineSpan();
}
