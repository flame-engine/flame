import 'package:flame/src/text/elements/document_element.dart';
import 'package:flame/src/text/nodes.dart';
import 'package:flame/src/text/styles/background_style.dart';
import 'package:flame/src/text/styles/block_style.dart';
import 'package:flutter/painting.dart';

class DocumentStyle {
  DocumentStyle({
    required this.width,
    required this.height,
    this.padding = EdgeInsets.zero,
    BackgroundStyle? background,
    BlockStyle? paragraphStyle,
  })  : paragraphStyle = paragraphStyle ?? BlockStyle(),
        backgroundStyle = background;

  /// Outer width of the document page.
  ///
  /// This width is computed between the left edge of the left border, and the
  /// right edge of the right border. Thus, it corresponds to the "border-box"
  /// box sizing model in HTML.
  double width;

  double height;

  EdgeInsets padding;

  BackgroundStyle? backgroundStyle;

  BlockStyle paragraphStyle;

  DocumentElement format(DocumentNode document) {
    return DocumentElement(document, this);
  }

  BlockStyle styleFor(BlockNode node) {
    if (node is ParagraphNode) {
      return paragraphStyle;
    }
    return BlockStyle();
  }
}
