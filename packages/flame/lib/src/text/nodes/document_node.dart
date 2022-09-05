import 'dart:math';

import 'package:flame/src/text/common/utils.dart';
import 'package:flame/src/text/elements/element.dart';
import 'package:flame/src/text/elements/group_element.dart';
import 'package:flame/src/text/nodes.dart';
import 'package:flame/src/text/nodes/paragraph_node.dart';
import 'package:flame/src/text/styles/document_style.dart';
import 'package:flutter/painting.dart';

class DocumentNode extends GroupBlockNode {
  DocumentNode(super.children);

  /// Applies [style] to this document, producing an object that can be rendered
  /// on a canvas. Parameters [width] and [height] serve as the fallback values
  /// if they were not specified in the style itself. However, they are ignored
  /// if `style.width` and `style.height` are provided.
  Element format(DocumentStyle style, {double? width, double? height}) {
    assert(
      style.width != null || width != null,
      'Width must be either provided explicitly or set in the stylesheet',
    );
    final out = <Element>[];
    final border = style.backgroundStyle?.borderWidths ?? EdgeInsets.zero;
    final padding = style.padding;

    final pageWidth = style.width ?? width!;
    final contentWidth = pageWidth - padding.horizontal - border.horizontal;
    final horizontalOffset = padding.left + border.left;
    var verticalOffset = border.top;
    var currentMargin = padding.top;
    for (final node in children) {
      final blockStyle = style.styleFor(node);
      verticalOffset += collapseMargin(currentMargin, blockStyle.margin.top);
      final nodeElement = (node as ParagraphNode).format(
        blockStyle,
        parentWidth: contentWidth,
      );
      nodeElement.translate(horizontalOffset, verticalOffset);
      out.add(nodeElement);
      currentMargin = blockStyle.margin.bottom;
      verticalOffset += nodeElement.height;
    }
    final pageHeight = max(
      height ?? 0,
      verticalOffset +
          collapseMargin(currentMargin, padding.bottom) +
          border.bottom,
    );
    final background = makeBackground(
      style.backgroundStyle,
      pageWidth,
      pageHeight,
    );
    if (background != null) {
      out.insert(0, background);
    }
    return GroupElement(pageWidth, pageHeight, out);
  }
}
