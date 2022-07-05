
import 'package:flame/src/text/document_element.dart';
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
  }) : backgroundPaint = backgroundPaint ?? Paint() {
    if (backgroundColor != null) {
      this.backgroundPaint.color = backgroundColor;
    }
  }

  double width;

  double height;

  EdgeInsets padding;

  Paint backgroundPaint;

  DocumentElement format(DocumentNode document) {
    return DocumentElement(document, this);
  }

  BlockStyle styleFor(BlockNode node) => throw UnimplementedError();
}
