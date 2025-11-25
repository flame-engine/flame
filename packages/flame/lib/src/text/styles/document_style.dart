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
    InlineTextStyle? codeText,
    InlineTextStyle? strikethroughText,
    Map<String, InlineTextStyle>? customStyles,
    BlockStyle? paragraph,
    BlockStyle? header1,
    BlockStyle? header2,
    BlockStyle? header3,
    BlockStyle? header4,
    BlockStyle? header5,
    BlockStyle? header6,
  }) : _text = FlameTextStyle.merge(DocumentStyle.defaultTextStyle, text),
       _boldText = FlameTextStyle.merge(BoldTextNode.defaultStyle, boldText),
       _italicText = FlameTextStyle.merge(
         ItalicTextNode.defaultStyle,
         italicText,
       ),
       _codeText = FlameTextStyle.merge(CodeTextNode.defaultStyle, codeText),
       _strikethroughText = FlameTextStyle.merge(
         StrikethroughTextNode.defaultStyle,
         strikethroughText,
       ),
       _customStyles = customStyles,
       _paragraph = FlameTextStyle.merge(ParagraphNode.defaultStyle, paragraph),
       _header1 = FlameTextStyle.merge(HeaderNode.defaultStyleH1, header1),
       _header2 = FlameTextStyle.merge(HeaderNode.defaultStyleH2, header2),
       _header3 = FlameTextStyle.merge(HeaderNode.defaultStyleH3, header3),
       _header4 = FlameTextStyle.merge(HeaderNode.defaultStyleH4, header4),
       _header5 = FlameTextStyle.merge(HeaderNode.defaultStyleH5, header5),
       _header6 = FlameTextStyle.merge(HeaderNode.defaultStyleH6, header6);

  final InlineTextStyle? _text;
  final InlineTextStyle? _boldText;
  final InlineTextStyle? _italicText;
  final InlineTextStyle? _codeText;
  final InlineTextStyle? _strikethroughText;
  final Map<String, InlineTextStyle>? _customStyles;
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
  InlineTextStyle get codeText => _codeText!;
  InlineTextStyle get strikethroughText => _strikethroughText!;

  InlineTextStyle? getCustomStyle(String className) {
    return _customStyles?[className];
  }

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
      text: FlameTextStyle.merge(_text, other.text),
      boldText: FlameTextStyle.merge(_boldText, other.boldText),
      italicText: FlameTextStyle.merge(_italicText, other.italicText),
      codeText: FlameTextStyle.merge(_codeText, other.codeText),
      strikethroughText: FlameTextStyle.merge(
        _strikethroughText,
        other.strikethroughText,
      ),
      background: merge(background, other.background) as BackgroundStyle?,
      paragraph: merge(paragraph, other.paragraph) as BlockStyle?,
      header1: merge(header1, other.header1) as BlockStyle?,
      header2: merge(header2, other.header2) as BlockStyle?,
      header3: merge(header3, other.header3) as BlockStyle?,
      header4: merge(header4, other.header4) as BlockStyle?,
      header5: merge(header5, other.header5) as BlockStyle?,
      header6: merge(header6, other.header6) as BlockStyle?,
    );
  }

  final Map<FlameTextStyle, Map<FlameTextStyle, FlameTextStyle>>
  _mergedStylesCache = {};

  /// Merges two [FlameTextStyle]s together, preferring the properties of
  /// [style2] if present, falling back to the properties of [style1].
  FlameTextStyle? merge(FlameTextStyle? style1, FlameTextStyle? style2) {
    if (style1 == null) {
      return style2;
    } else if (style2 == null) {
      return style1;
    } else {
      return (_mergedStylesCache[style1] ??= {})[style2] ??= style1.copyWith(
        style2,
      );
    }
  }
}
