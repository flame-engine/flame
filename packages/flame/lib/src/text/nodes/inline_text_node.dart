import 'package:flame/text.dart';

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

  TextNodeLayoutBuilder get layoutBuilder;
}

/// Stateful helper that lays out an [InlineTextNode] one line at a time.
///
/// Lines may only be broken at whitespace, so pieces of adjacent nodes that
/// touch without whitespace in between (like `**Bold**,`) form a single
/// unbreakable run. [leadingRunWidth], [hasBreakOpportunity] and the
/// `trailingWidth` parameter of [layOutNextLine] let a parent keep such runs
/// on the same line.
abstract class TextNodeLayoutBuilder {
  /// Lays out as much of the remaining content as fits in [availableWidth],
  /// or returns `null` if not even its first word fits.
  ///
  /// If the returned piece reaches the end of the content and the content
  /// does not end with whitespace, the piece is glued to whatever follows it,
  /// so it must also leave [trailingWidth] of space for that. At the start of
  /// a line a run that cannot fit anyway is laid out ignoring
  /// [trailingWidth], so that layout can still make progress.
  InlineTextElement? layOutNextLine(
    double availableWidth, {
    required bool isStartOfLine,
    double trailingWidth = 0,
  });

  /// Whether all of the content has been laid out so far.
  bool get isDone;

  /// The width of the remaining content up to its first whitespace (all of
  /// it if [hasBreakOpportunity] is false), which is glued to any content
  /// that precedes it without whitespace.
  double get leadingRunWidth;

  /// Whether the remaining content contains any whitespace a line could be
  /// broken at. If not, a run glued to its start continues past its end.
  bool get hasBreakOpportunity;
}
