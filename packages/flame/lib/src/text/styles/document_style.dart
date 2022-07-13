import 'package:flame/src/text/nodes/block_node.dart';
import 'package:flame/src/text/nodes/paragraph_node.dart';
import 'package:flame/src/text/styles/background_style.dart';
import 'package:flame/src/text/styles/block_style.dart';
import 'package:flame/src/text/styles/overflow.dart';
import 'package:flame/src/text/styles/style.dart';
import 'package:flutter/painting.dart';
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
class DocumentStyle extends Style<DocumentStyle> {
  DocumentStyle({
    this.width,
    this.height,
    EdgeInsets? padding,
    BackgroundStyle? background,
    BlockStyle? paragraphStyle,
  })  : padding = padding ?? EdgeInsets.zero,
        backgroundStyle = background {
    paragraphStyle = (paragraphStyle ?? defaultParagraphStyle).acquire(this);
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
  final BackgroundStyle? backgroundStyle;

  /// Style for paragraph nodes in the document.
  late final BlockStyle paragraphStyle;

  static BlockStyle defaultParagraphStyle = BlockStyle();

  @override
  DocumentStyle clone() => copyWith();

  DocumentStyle copyWith({
    double? width,
    double? height,
    EdgeInsets? padding,
    BackgroundStyle? background,
    BlockStyle? paragraphStyle,
  }) {
    return DocumentStyle(
      width: width ?? this.width,
      height: height ?? this.height,
      padding: padding ?? this.padding,
      background: background ?? backgroundStyle,
      paragraphStyle: paragraphStyle ?? this.paragraphStyle.clone(),
    );
  }

  @internal
  BlockStyle styleForBlockNode(BlockNode node) {
    if (node is ParagraphNode) {
      return paragraphStyle;
    }
    return BlockStyle();
  }
}
