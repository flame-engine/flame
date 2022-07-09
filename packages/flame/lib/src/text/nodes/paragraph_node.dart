import 'dart:ui';

import 'package:flame/src/text/elements/block_element.dart';
import 'package:flame/src/text/elements/group_element.dart';
import 'package:flame/src/text/elements/rect_element.dart';
import 'package:flame/src/text/formatters/text_painter_text_formatter.dart';
import 'package:flame/src/text/inline/text_painter_text_element.dart';
import 'package:flame/src/text/nodes.dart';
import 'package:flame/src/text/styles/block_style.dart';
import 'package:flutter/painting.dart' as painting;

class ParagraphNode extends BlockNode {
  // ParagraphNode._(this.child);
  ParagraphNode.simple(String text)
      : child = GroupTextNode([PlainTextNode(text)]);

  final GroupTextNode child;

  BlockElement format(BlockStyle style, {required double parentWidth}) {
    final text = (child.children.first as PlainTextNode).text;
    final formatter = TextPainterTextFormatter(
      style: const painting.TextStyle(fontSize: 16),
    );
    final words = text.split(' ');
    final lines = <TextPainterTextElement>[];
    var verticalOffset = 0.0;
    var i0 = 0;
    var i1 = 1;
    var startNewLine = true;
    while (i1 <= words.length) {
      final lineText = words.sublist(i0, i1).join(' ');
      final formattedLine = formatter.format(lineText);
      if (formattedLine.metrics.width <= parentWidth || i1 - i0 == 1) {
        formattedLine.translate(
          0,
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
    final bg = style.background?.format(parentWidth, verticalOffset);
    final elements = bg == null? lines : [bg, ...lines];
    return GroupElement(parentWidth, verticalOffset, elements);
  }
}
