import 'package:flame/src/text/nodes/block_node.dart';
import 'package:flame/src/text/nodes/header_node.dart';
import 'package:flame/src/text/nodes/paragraph_node.dart';
import 'package:flame/src/text/styles/background_style.dart';
import 'package:flame/src/text/styles/block_style.dart';
import 'package:flame/src/text/styles/overflow.dart';
import 'package:flame/src/text/styles/style.dart';
import 'package:flutter/cupertino.dart';
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
  const DocumentStyle({
    this.width,
    this.height,
    this.padding = EdgeInsets.zero,
    this.background,
    this.paragraph = ParagraphNode.defaultStyle,
    this.header1 = HeaderNode.defaultStyleH1,
    this.header2 = HeaderNode.defaultStyleH2,
    this.header3 = HeaderNode.defaultStyleH3,
    this.header4 = HeaderNode.defaultStyleH4,
    this.header5 = HeaderNode.defaultStyleH5,
    this.header6 = HeaderNode.defaultStyleH6,
  });

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

  /// Style for [ParagraphNode]s.
  final BlockStyle paragraph;

  /// Styles for [HeaderNode]s, levels 1 to 6.
  final BlockStyle header1;
  final BlockStyle header2;
  final BlockStyle header3;
  final BlockStyle header4;
  final BlockStyle header5;
  final BlockStyle header6;

  @override
  DocumentStyle mergeWith(DocumentStyle other) {
    return DocumentStyle(
      width: other.width ?? width,
      height: other.height ?? height,
      padding: other.padding,
      background: Style.merge(other.background, background)! as BackgroundStyle,
      paragraph: Style.merge(other.paragraph, paragraph)! as BlockStyle,
      header1: Style.merge(other.header1, header1)! as BlockStyle,
      header2: Style.merge(other.header2, header2)! as BlockStyle,
      header3: Style.merge(other.header3, header3)! as BlockStyle,
      header4: Style.merge(other.header4, header4)! as BlockStyle,
      header5: Style.merge(other.header5, header5)! as BlockStyle,
      header6: Style.merge(other.header6, header6)! as BlockStyle,
    );
  }

  @internal
  BlockStyle styleFor(BlockNode node) {
    if (node is ParagraphNode) {
      return paragraph;
    }
    if (node is HeaderNode) {
      switch (node.level) {
        case 1:
          return header1;
        case 2:
          return header2;
        case 3:
          return header3;
        case 4:
          return header4;
        case 5:
          return header5;
        default:
          return header6;
      }
    }
    return const BlockStyle();
  }
}
