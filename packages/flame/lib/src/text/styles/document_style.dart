import 'package:flame/src/text/elements/document_element.dart';
import 'package:flame/src/text/nodes.dart';
import 'package:flame/src/text/styles/background_style.dart';
import 'package:flame/src/text/styles/block_style.dart';
import 'package:flutter/painting.dart';

/// [DocumentStyle] is a user-facing description of how to render a body of
/// text; it roughly corresponds to a stylesheet in HTML.
///
/// This class represents a top-level style sheet, comprised of properties that
/// describe the document as a whole (as opposed to lower-level styles that
/// represent more granular elements such as paragraphs, headers, etc).
class DocumentStyle {
  DocumentStyle({
    this.width,
    this.height,
    this.padding = EdgeInsets.zero,
    BackgroundStyle? background,
    BlockStyle? paragraphStyle,
  })  : paragraphStyle = paragraphStyle ?? BlockStyle(),
        backgroundStyle = background;

  /// Outer width of the document page.
  ///
  /// This width is the distance between the left edge of the left border, and
  /// the right edge of the right border. Thus, it corresponds to the
  /// "border-box" box sizing model in HTML.
  double? width;

  double? height;

  EdgeInsets padding;

  BackgroundStyle? backgroundStyle;

  BlockStyle paragraphStyle;

  /// Applies the current style to the given [document], producing an object
  /// that can be rendered on a canvas. Parameters [width] and [height] serve
  /// as the fallback values if they were not specified in the style itself.
  /// However, they are ignored if [this.width] and [this.height] are provided.
  DocumentElement format(
    DocumentNode document, {
    double? width,
    double? height,
  }) {
    return DocumentElement(
      document: document,
      style: this,
      width: width ?? this.width!,
      height: height ?? this.height ?? 0,
    );
  }

  BlockStyle styleForBlockNode(BlockNode node) {
    if (node is ParagraphNode) {
      return paragraphStyle;
    }
    return BlockStyle();
  }
}
