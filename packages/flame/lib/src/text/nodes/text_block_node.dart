import 'package:flame/src/text/common/utils.dart';
import 'package:flame/src/text/elements/block_element.dart';
import 'package:flame/src/text/elements/group_element.dart';
import 'package:flame/src/text/elements/text_element.dart';
import 'package:flame/src/text/elements/text_painter_text_element.dart';
import 'package:flame/src/text/nodes/block_node.dart';
import 'package:flame/src/text/nodes/group_text_node.dart';
import 'package:flame/src/text/nodes/plain_text_node.dart';
import 'package:flame/src/text/nodes/text_node.dart';

abstract class TextBlockNode extends BlockNode {
  TextBlockNode(this.child);

  final TextNode child;

  /// Converts this node into a [BlockElement].
  ///
  /// All late variables must be initialized prior to calling this method.
  @override
  BlockElement format(double availableWidth) {
    final text = ((child as GroupTextNode).children[0] as PlainTextNode).text;
    final formatter = textStyle.asTextFormatter();
    final blockWidth = availableWidth;
    final contentWidth = blockWidth - style.padding.horizontal;
    final horizontalOffset = style.padding.left;
    var verticalOffset = style.padding.top;

    final words = text.split(' ');
    final lines = <TextPainterTextElement>[];
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
    final bg = makeBackground(style.background, blockWidth, verticalOffset);
    final elements = bg == null ? lines : [bg, ...lines];
    return GroupElement(
      width: blockWidth,
      height: verticalOffset,
      children: elements,
    );
  }

  BlockElement format2(double availableWidth) {
    final layoutBuilder = child.layoutBuilder;
    final blockWidth = availableWidth;
    final contentWidth = blockWidth - style.padding.horizontal;

    final lines = <TextElement>[];
    final horizontalOffset = style.padding.left;
    var verticalOffset = style.padding.top;
    while (!layoutBuilder.isDone) {
      final element = layoutBuilder.layOutNextLine(contentWidth);
      if (element == null) {
        // Not enough horizontal space to lay out. For now we just stop the
        // layout altogether cutting off the remainder of the content. But is
        // there a better alternative?
        break;
      } else {
        element.translate(horizontalOffset, verticalOffset);
        lines.add(element);
        verticalOffset += element.metrics.height;
      }
    }
    verticalOffset += style.padding.bottom;
    final bg = makeBackground(style.background, blockWidth, verticalOffset);
    final elements = bg == null ? lines : [bg, ...lines];
    return GroupElement(
      width: blockWidth,
      height: verticalOffset,
      children: elements,
    );
  }
}
