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
    return GroupElement(parentWidth, verticalOffset, lines);
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
