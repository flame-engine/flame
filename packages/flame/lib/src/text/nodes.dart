import 'package:flame/src/text/common/utils.dart';
import 'package:flame/src/text/elements/element.dart';
import 'package:flame/src/text/elements/group_element.dart';
import 'package:flame/src/text/styles/document_style.dart';

/// An abstract base class for all entities with "block" placement rules.
abstract class BlockNode {}

class GroupBlockNode extends BlockNode {
  GroupBlockNode(this.children);

  final List<BlockNode> children;
}

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
      final nodeElement = blockStyle.format(node, parentWidth: contentWidth);
      nodeElement.translate(horizontalOffset, verticalOffset);
      elements.add(nodeElement);
      currentMargin = blockStyle.margin.bottom;
    }
    final height = verticalOffset +
        collapseMargin(currentMargin, style.padding.bottom) +
        (borders?.bottom ?? 0);
    final background = style.backgroundStyle?.format(documentWidth, height);
    if (background != null) {
      background.layout();
      elements.insert(0, background);
    }
    return GroupElement(elements);
  }
}

class ParagraphNode extends BlockNode {
  ParagraphNode(this.child);

  final GroupTextNode child;
}

class HeaderNode extends BlockNode {
  HeaderNode(this.child, {required this.level});

  final GroupTextNode child;
  final int level;
}

class BlockquoteNode extends GroupBlockNode {
  BlockquoteNode(super.children);
}

abstract class TextNode {}

class PlainTextNode extends TextNode {
  PlainTextNode(this.text);

  final String text;
}

class GroupTextNode extends TextNode {
  GroupTextNode(this.children);

  final List<TextNode> children;
}

class BoldTextNode extends GroupTextNode {
  BoldTextNode(super.children);
}

class ItalicTextNode extends GroupTextNode {
  ItalicTextNode(super.children);
}

class StrikethroughTextNode extends GroupTextNode {
  StrikethroughTextNode(super.children);
}

class HighlightedTextNode extends GroupTextNode {
  HighlightedTextNode(super.children);
}
