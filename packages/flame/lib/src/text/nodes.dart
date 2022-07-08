import 'dart:math';

import 'package:flame/src/text/common/utils.dart';
import 'package:flame/src/text/elements/element.dart';
import 'package:flame/src/text/elements/group_element.dart';
import 'package:flame/src/text/formatters/text_painter_text_formatter.dart';
import 'package:flame/src/text/inline/text_painter_text_element.dart';
import 'package:flame/src/text/styles/block_style.dart';
import 'package:flame/src/text/styles/document_style.dart';
import 'package:flutter/painting.dart' as painting;

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
      // final nodeElement = blockStyle.format(node, parentWidth: contentWidth);
      final nodeElement = (node as ParagraphNode).format(
        blockStyle,
        parentWidth: contentWidth,
      );
      nodeElement.translate(horizontalOffset, verticalOffset);
      elements.add(nodeElement);
      currentMargin = blockStyle.margin.bottom;
    }
    final documentHeight = max(height ?? 0, verticalOffset +
        collapseMargin(currentMargin, style.padding.bottom) +
        (borders?.bottom ?? 0),);
    final background = style.backgroundStyle?.format(documentWidth, documentHeight);
    if (background != null) {
      background.layout();
      elements.insert(0, background);
    }
    return GroupElement(elements);
  }
}

class ParagraphNode extends BlockNode {
  ParagraphNode._(this.child);
  ParagraphNode.simple(String text)
    : child = GroupTextNode([PlainTextNode(text)]);

  final GroupTextNode child;

  Element format(BlockStyle style, {required double parentWidth}) {
    final text = (child.children.first as PlainTextNode).text;
    final formatter = TextPainterTextFormatter(
      style: const painting.TextStyle(fontSize: 16),
    );
    final words = text.split(' ');
    final lines = <TextPainterTextElement>[];
    TextPainterTextElement? currentLine;
    var i0 = 0;
    var verticalOffset = 0.0;
    for (var i = 0; i < words.length; i++) {
      final lineText = words.sublist(i0, i + 1).join(' ');
      final formattedLine = formatter.format(lineText);
      if (formattedLine.metrics.width > parentWidth) {
        if (currentLine != null) {
          lines.add(currentLine..translate(0, verticalOffset));
          verticalOffset += currentLine.metrics.height;
        }
        i0 = i;
      }
      currentLine = formattedLine;
    }
    if (currentLine != null) {
      lines.add(currentLine..translate(0, verticalOffset));
    }
    return GroupElement(lines);
  }
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
