import 'package:flame/src/text/elements/block_element.dart';
import 'package:flame/src/text/elements/group_element.dart';
import 'package:flame/src/text/formatters/text_painter_text_formatter.dart';
import 'package:flame/src/text/inline/text_painter_text_element.dart';
import 'package:flame/src/text/nodes.dart';
import 'package:flame/src/text/nodes/block_node.dart';
import 'package:flame/src/text/styles/block_style.dart';
import 'package:flutter/painting.dart' as painting;

class ParagraphNode extends BlockNode {
  ParagraphNode.simple(String text)
      : child = GroupTextNode([PlainTextNode(text)]);

  final GroupTextNode child;

  BlockElement format(BlockStyle style, {required double parentWidth}) {
    final text = (child.children.first as PlainTextNode).text;
    final formatter = TextPainterTextFormatter(
      style: const painting.TextStyle(fontSize: 16),
    );
    final contentWidth = parentWidth - style.padding.horizontal;
    final horizontalOffset = style.padding.left;

    final words = text.split(' ');
    final lines = <TextPainterTextElement>[];
    var verticalOffset = style.padding.top;
    var i0 = 0;
    var i1 = 1;
    var startNewLine = true;
    while (i1 <= words.length) {
      final lineText = words.sublist(i0, i1).join(' ');
      final formattedLine = formatter.format(lineText);
      if (formattedLine.metrics.width <= contentWidth || i1 - i0 == 1) {
        formattedLine.translate(
          horizontalOffset,
          verticalOffset + formattedLine.metrics.ascent,
        );
        if (startNewLine) {
          lines.add(formattedLine);
          startNewLine = false;
        } else {
          lines[lines.length - 1] = formattedLine;
        }
        i1++;
      } else {
        i0 = i1 - 1;
        startNewLine = true;
        verticalOffset += lines.last.metrics.height;
      }
    }
    if (!startNewLine) {
      verticalOffset += lines.last.metrics.height;
    }
    verticalOffset += style.padding.bottom;
    final bg = makeBackground(style.background, parentWidth, verticalOffset);
    final elements = bg == null ? lines : [bg, ...lines];
    return GroupElement(parentWidth, verticalOffset, elements);
  }
}
