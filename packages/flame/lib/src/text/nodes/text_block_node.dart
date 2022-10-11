import 'package:flame/src/text/common/utils.dart';
import 'package:flame/src/text/elements/block_element.dart';
import 'package:flame/src/text/elements/group_element.dart';
import 'package:flame/src/text/elements/text_element.dart';
import 'package:flame/src/text/nodes/block_node.dart';
import 'package:flame/src/text/nodes/text_node.dart';
import 'package:flame/src/text/styles/document_style.dart';
import 'package:flame/src/text/styles/flame_text_style.dart';
import 'package:meta/meta.dart';

abstract class TextBlockNode extends BlockNode {
  TextBlockNode(this.child);

  final TextNode child;

  @mustCallSuper
  @override
  void fillStyles(DocumentStyle stylesheet, FlameTextStyle parentTextStyle) {
    child.fillStyles(stylesheet, parentTextStyle);
  }

  /// Converts this node into a [BlockElement].
  ///
  /// All late variables must be initialized prior to calling this method.
  @override
  BlockElement format(double availableWidth) {
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
        final metrics = element.metrics;
        assert(metrics.left == 0 && metrics.baseline == 0);
        element.translate(horizontalOffset, verticalOffset + metrics.ascent);
        lines.add(element);
        verticalOffset += metrics.height;
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
