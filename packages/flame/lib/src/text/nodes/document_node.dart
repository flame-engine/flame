import 'dart:math';

import 'package:flame/src/text/common/utils.dart';
import 'package:flame/src/text/elements/element.dart';
import 'package:flame/src/text/elements/group_element.dart';
import 'package:flame/src/text/nodes.dart';
import 'package:flame/src/text/styles/document_style.dart';

class DocumentNode extends GroupBlockNode {
  DocumentNode(super.children);

  /// Applies [style] to this document, producing an object that can be rendered
  /// on a canvas. Parameters [width] and [height] serve as the fallback values
  /// if they were not specified in the style itself. However, they are ignored
  /// if `style.width` and `style.height` are provided.
  Element format(DocumentStyle style, {double? width, double? height}) {
    final elements = <Element>[];
    final borders = style.backgroundStyle?.borderWidths;

    final documentWidth = width ?? style.width!;
    final contentWidth =
        documentWidth - style.padding.horizontal - (borders?.horizontal ?? 0);
    final horizontalOffset = style.padding.left + (borders?.left ?? 0);
    var verticalOffset = style.padding.top + (borders?.top ?? 0);
    var currentMargin = style.padding.top;
    for (final node in children) {
      final blockStyle = style.styleForBlockNode(node);
      verticalOffset += collapseMargin(currentMargin, blockStyle.margin.top);
      // final nodeElement = blockStyle.format(node, parentWidth: contentWidth);
      final nodeElement = (node as ParagraphNode).format(
        blockStyle,
        parentWidth: contentWidth,
      );
      nodeElement.translate(horizontalOffset, verticalOffset);
      elements.add(nodeElement);
      currentMargin = blockStyle.margin.bottom;
    }
    final documentHeight = max(
      height ?? 0,
      verticalOffset +
          collapseMargin(currentMargin, style.padding.bottom) +
          (borders?.bottom ?? 0),
    );
    final background =
        style.backgroundStyle?.format(documentWidth, documentHeight);
    if (background != null) {
      // background.layout();
      elements.insert(0, background);
    }
    return GroupElement(elements);
  }
}
