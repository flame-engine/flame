import 'package:flame/src/text/common/utils.dart';
import 'package:flame/src/text/elements/block_element.dart';
import 'package:flame/src/text/elements/group_element.dart';
import 'package:flame/src/text/inline/text_painter_text_element.dart';
import 'package:flame/src/text/nodes/text_nodes.dart';
import 'package:flame/src/text/styles/block_style.dart';
import 'package:flame/src/text/styles/document_style.dart';
import 'package:flame/src/text/styles/text_style.dart';
import 'package:meta/meta.dart';

/// [BlockNode] is a base class for all nodes with "block" placement rules.
///
/// A block node is a structural piece of text such that the
abstract class BlockNode {
  BlockNode(this.child);

  final GroupTextNode child;

  late BlockStyle style;
  late TextStyle textStyle;
  late double parentWidth;

  /// Converts this node into a [BlockElement].
  ///
  /// All late variables must be initialized prior to calling this method.
  @internal
  BlockElement format() {
    final text = (child.children.first as PlainTextNode).text;
    final formatter = textStyle.asTextFormatter();
    final contentWidth = parentWidth - style.padding.horizontal;
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
    final bg = makeBackground(style.background, parentWidth, verticalOffset);
    final elements = bg == null ? lines : [bg, ...lines];
    return GroupElement(parentWidth, verticalOffset, elements);
  }

  void fillStyles(DocumentStyle stylesheet, TextStyle parentTextStyle);
}
