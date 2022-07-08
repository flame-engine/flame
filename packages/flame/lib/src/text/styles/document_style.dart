import 'package:flame/src/text/common/utils.dart';
import 'package:flame/src/text/elements/element.dart';
import 'package:flame/src/text/elements/group_element.dart';
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
  Element format(
    DocumentNode document, {
    double? width,
    double? height,
  }) {
    final elements = <Element>[];
    final borders = backgroundStyle?.borderWidths;

    final documentWidth = width ?? this.width!;
    final contentWidth =
        documentWidth - padding.horizontal - (borders?.horizontal ?? 0);
    final horizontalOffset = padding.left + (borders?.left ?? 0);
    var verticalOffset = padding.top + (borders?.top ?? 0);
    var currentMargin = padding.top;
    for (final node in document.children) {
      final blockStyle = styleForBlockNode(node);
      verticalOffset += collapseMargin(currentMargin, blockStyle.margin.top);
      final nodeElement = blockStyle.format(node, parentWidth: contentWidth);
      nodeElement.translate(horizontalOffset, verticalOffset);
      elements.add(nodeElement);
      currentMargin = blockStyle.margin.bottom;
    }
    final height = verticalOffset +
        collapseMargin(currentMargin, padding.bottom) +
        (borders?.bottom ?? 0);
    final background = backgroundStyle?.format(documentWidth, height);
    if (background != null) {
      background.layout();
      elements.insert(0, background);
    }
    return GroupElement(elements);
  }

  BlockStyle styleForBlockNode(BlockNode node) {
    if (node is ParagraphNode) {
      return paragraphStyle;
    }
    return BlockStyle();
  }
}
