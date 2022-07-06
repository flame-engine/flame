import 'package:flame/src/text/block/document_element.dart';
import 'package:flame/src/text/nodes.dart';
import 'package:flame/src/text/styles/block_style.dart';
import 'package:flutter/painting.dart';

class DocumentStyle {
  DocumentStyle({
    required this.width,
    required this.height,
    this.padding = EdgeInsets.zero,
    Color? backgroundColor,
    Paint? backgroundPaint,
    BlockStyle? paragraphStyle,
  })  : backgroundPaint = backgroundPaint ?? Paint(),
        paragraphStyle = paragraphStyle ?? BlockStyle() {
    if (backgroundColor != null) {
      this.backgroundPaint.color = backgroundColor;
    }
  }

  double width;

  double height;

  EdgeInsets padding;

  Paint backgroundPaint;

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
