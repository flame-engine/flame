import 'package:flame/src/text/styles/overflow.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart' show EdgeInsets;

/// [DocumentStyle] is a user-facing description of how to render an entire
/// body of text; it roughly corresponds to a stylesheet in HTML.
///
/// This class represents a top-level style sheet, comprised of properties that
/// describe the document as a whole (as opposed to lower-level styles that
/// represent more granular elements such as paragraphs, headers, etc).
///
/// All styles that collectively describe how to render text are organized into
/// a tree, with [DocumentStyle] at the root.
class DocumentStyle extends FlameTextStyle {
  DocumentStyle({
    this.width,
    this.height,
    this.padding = EdgeInsets.zero,
    this.background,
    InlineTextStyle? text,
    InlineTextStyle? boldText,
    InlineTextStyle? italicText,
    BlockStyle? paragraph,
    BlockStyle? header1,
    BlockStyle? header2,
    BlockStyle? header3,
    BlockStyle? header4,
    BlockStyle? header5,
    BlockStyle? header6,
  })  : _text = FlameTextStyle.merge(text, DocumentStyle.defaultTextStyle),
        _boldText = FlameTextStyle.merge(boldText, BoldTextNode.defaultStyle),
        _italicText =
            FlameTextStyle.merge(italicText, ItalicTextNode.defaultStyle),
        _paragraph =
            FlameTextStyle.merge(paragraph, ParagraphNode.defaultStyle),
        _header1 = FlameTextStyle.merge(header1, HeaderNode.defaultStyleH1),
        _header2 = FlameTextStyle.merge(header2, HeaderNode.defaultStyleH2),
        _header3 = FlameTextStyle.merge(header3, HeaderNode.defaultStyleH3),
        _header4 = FlameTextStyle.merge(header4, HeaderNode.defaultStyleH4),
        _header5 = FlameTextStyle.merge(header5, HeaderNode.defaultStyleH5),
        _header6 = FlameTextStyle.merge(header6, HeaderNode.defaultStyleH6);

  final InlineTextStyle? _text;
  final InlineTextStyle? _boldText;
  final InlineTextStyle? _italicText;
  final BlockStyle? _paragraph;
  final BlockStyle? _header1;
  final BlockStyle? _header2;
  final BlockStyle? _header3;
  final BlockStyle? _header4;
  final BlockStyle? _header5;
  final BlockStyle? _header6;

  /// Outer width of the document page.
  ///
  /// This width is the distance between the left edge of the left border, and
  /// the right edge of the right border. Thus, it corresponds to the
  /// "border-box" box sizing model in HTML.
  ///
  /// If this property is `null`, then the page width must be provided when
  /// formatting a document.
  final double? width;

  /// Outer height of the document page.
  ///
  /// If the [overflow] property is [Overflow.expand], then the height parameter
  /// is treated as a minimum height, in other cases the height is obeyed
  /// strictly.
  ///
  /// If this property is `null`, then the page height must be provided when
  /// formatting a document (except for the overflow-expand mode, when the
  /// value of [height] defaults to 0).
  final double? height;

  /// Behavior of the document when the amount of content that needs to be laid
  /// out exceeds the provided [height]. See the [Overflow] enum description for
  /// more details.
  Overflow get overflow => Overflow.expand;

  /// The distance from the outer edges of the page to the inner content box of
  /// the document.
  ///
  /// Note that the padding is computed from the outer edge of the page, unlike
  /// HTML where it is computed from the inner edge of the border box.
  ///
  /// If the document's horizontal padding exceeds its width, an exception will
  /// be thrown.
  final EdgeInsets padding;

  /// If present, describes what kind of background and borders to draw for the
  /// document page(s).
  final BackgroundStyle? background;

  InlineTextStyle get text => _text!;
  InlineTextStyle get boldText => _boldText!;
  InlineTextStyle get italicText => _italicText!;

  /// Style for [ParagraphNode]s.
  BlockStyle get paragraph => _paragraph!;

  /// Styles for [HeaderNode]s, levels 1 to 6.
  BlockStyle get header1 => _header1!;
  BlockStyle get header2 => _header2!;
  BlockStyle get header3 => _header3!;
  BlockStyle get header4 => _header4!;
  BlockStyle get header5 => _header5!;
  BlockStyle get header6 => _header6!;

  static InlineTextStyle defaultTextStyle = InlineTextStyle(fontSize: 16.0);

  @override
  DocumentStyle copyWith(DocumentStyle other) {
    return DocumentStyle(
      width: other.width ?? width,
      height: other.height ?? height,
      padding: other.padding,
      background: merge(other.background, background)! as BackgroundStyle,
      paragraph: merge(other.paragraph, paragraph)! as BlockStyle,
      header1: merge(other.header1, header1)! as BlockStyle,
      header2: merge(other.header2, header2)! as BlockStyle,
      header3: merge(other.header3, header3)! as BlockStyle,
      header4: merge(other.header4, header4)! as BlockStyle,
      header5: merge(other.header5, header5)! as BlockStyle,
      header6: merge(other.header6, header6)! as BlockStyle,
    );
  }

  final Map<FlameTextStyle, Map<FlameTextStyle, FlameTextStyle>>
      _mergedStylesCache = {};
  FlameTextStyle? merge(FlameTextStyle? style1, FlameTextStyle? style2) {
    if (style1 == null) {
      return style2;
    } else if (style2 == null) {
      return style1;
    } else {
      return (_mergedStylesCache[style1] ??= {})[style2] ??=
          style1.copyWith(style2);
    }
  }
}
