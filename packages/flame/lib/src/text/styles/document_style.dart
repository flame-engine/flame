import 'package:flame/src/text/block/document_element.dart';
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
