import 'package:flame/src/text/nodes/block_node.dart';
import 'package:flame/src/text/nodes/header_node.dart';
import 'package:flame/src/text/nodes/paragraph_node.dart';
import 'package:flame/src/text/styles/background_style.dart';
import 'package:flame/src/text/styles/block_style.dart';
import 'package:flame/src/text/styles/overflow.dart';
import 'package:flame/src/text/styles/style.dart';
import 'package:flutter/painting.dart' show EdgeInsets;
import 'package:meta/meta.dart';

/// [DocumentStyle] is a user-facing description of how to render an entire
/// body of text; it roughly corresponds to a stylesheet in HTML.
///
/// This class represents a top-level style sheet, comprised of properties that
/// describe the document as a whole (as opposed to lower-level styles that
/// represent more granular elements such as paragraphs, headers, etc).
///
/// All styles that collectively describe how to render text are organized into
/// a tree, with [DocumentStyle] at the root.
class DocumentStyle extends Style {
  DocumentStyle({
    this.width,
    this.height,
    EdgeInsets? padding,
    BackgroundStyle? background,
    BlockStyle? paragraphStyle,
    BlockStyle? header1Style,
    BlockStyle? header2Style,
    BlockStyle? header3Style,
    BlockStyle? header4Style,
    BlockStyle? header5Style,
    BlockStyle? header6Style,
  }) : padding = padding ?? EdgeInsets.zero {
    backgroundStyle = acquire(background);
    this.paragraphStyle = acquire(paragraphStyle ?? defaultParagraphStyle)!;
    this.header1Style = acquire(header1Style ?? defaultHeader1Style)!;
    this.header2Style = acquire(header2Style ?? defaultHeader2Style)!;
    this.header3Style = acquire(header3Style ?? defaultHeader3Style)!;
    this.header4Style = acquire(header4Style ?? defaultHeader4Style)!;
    this.header5Style = acquire(header5Style ?? defaultHeader5Style)!;
    this.header6Style = acquire(header6Style ?? defaultHeader6Style)!;
  }

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
  final Overflow overflow = Overflow.expand;

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
  late final BackgroundStyle? backgroundStyle;

  /// Style for paragraph nodes in the document.
  late final BlockStyle paragraphStyle;

  /// Style for level-1 headers.
  late final BlockStyle header1Style;

  /// Style for level-2 headers.
  late final BlockStyle header2Style;

  /// Style for level-3 headers.
  late final BlockStyle header3Style;

  /// Style for level-4 headers.
  late final BlockStyle header4Style;

  /// Style for level-5 headers.
  late final BlockStyle header5Style;

  /// Style for level-6 headers.
  late final BlockStyle header6Style;

  static BlockStyle defaultParagraphStyle = BlockStyle();
  static BlockStyle defaultHeader1Style = BlockStyle();
  static BlockStyle defaultHeader2Style = BlockStyle();
  static BlockStyle defaultHeader3Style = BlockStyle();
  static BlockStyle defaultHeader4Style = BlockStyle();
  static BlockStyle defaultHeader5Style = BlockStyle();
  static BlockStyle defaultHeader6Style = BlockStyle();

  @override
  DocumentStyle clone() => copyWith();

  DocumentStyle copyWith({
    double? width,
    double? height,
    EdgeInsets? padding,
    BackgroundStyle? background,
    BlockStyle? paragraphStyle,
    BlockStyle? header1Style,
    BlockStyle? header2Style,
    BlockStyle? header3Style,
    BlockStyle? header4Style,
    BlockStyle? header5Style,
    BlockStyle? header6Style,
  }) {
    return DocumentStyle(
      width: width ?? this.width,
      height: height ?? this.height,
      padding: padding ?? this.padding,
      background: background ?? backgroundStyle,
      paragraphStyle: paragraphStyle ?? this.paragraphStyle,
      header1Style: header1Style ?? this.header1Style,
      header2Style: header2Style ?? this.header2Style,
      header3Style: header3Style ?? this.header3Style,
      header4Style: header4Style ?? this.header4Style,
      header5Style: header5Style ?? this.header5Style,
      header6Style: header6Style ?? this.header6Style,
    );
  }

  @internal
  BlockStyle styleFor(BlockNode node) {
    if (node is ParagraphNode) {
      return paragraphStyle;
    }
    if (node is HeaderNode) {
      switch (node.level) {
        case 1:
          return header1Style;
        case 2:
          return header2Style;
        case 3:
          return header3Style;
        case 4:
          return header4Style;
        case 5:
          return header5Style;
        default:
          return header6Style;
      }
    }
    return BlockStyle();
  }
}
