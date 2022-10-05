import 'package:flame/src/text/common/utils.dart';
import 'package:flame/src/text/elements/block_element.dart';
import 'package:flame/src/text/elements/element.dart';
import 'package:flame/src/text/elements/group_element.dart';
import 'package:flame/src/text/nodes/block_node.dart';
import 'package:flame/src/text/styles/document_style.dart';
import 'package:flame/src/text/styles/flame_text_style.dart';
import 'package:meta/meta.dart';

/// [ColumnNode] is a block node containing other block nodes arranged as a
/// column.
///
/// During formatting, produces an element which is as wide as the available
/// width, and tall enough to fit all the available children elements.
abstract class ColumnNode extends BlockNode {
  ColumnNode(this.children);

  final List<BlockNode> children;

  @override
  BlockElement format(double availableWidth) {
    final out = <Element>[];
    final blockWidth = availableWidth;
    final padding = style.padding;

    var verticalOffset = 0.0;
    var currentMargin = padding.top;
    for (final node in children) {
      final nodeMargins = node.style.margin;
      final marginLeft = collapseMargin(padding.left, nodeMargins.left);
      final marginRight = collapseMargin(padding.right, nodeMargins.right);
      final nodeAvailableWidth = blockWidth - marginLeft - marginRight;
      final nodeElement = node.format(nodeAvailableWidth);
      out.add(nodeElement);

      verticalOffset += collapseMargin(currentMargin, nodeMargins.top);
      nodeElement.translate(marginLeft, verticalOffset);
      verticalOffset += nodeElement.height;
      currentMargin = nodeMargins.bottom;
    }
    // Do not collapse padding if there are no children.
    final blockHeight = children.isEmpty
        ? padding.vertical
        : verticalOffset + collapseMargin(currentMargin, padding.bottom);
    final background =
        makeBackground(style.background, blockWidth, blockHeight);
    if (background != null) {
      out.insert(0, background);
    }
    return GroupElement(
      width: blockWidth,
      height: blockHeight,
      children: out,
    );
  }

  @mustCallSuper
  @override
  void fillStyles(DocumentStyle rootStyle, FlameTextStyle parentTextStyle) {
    for (final node in children) {
      node.fillStyles(rootStyle, parentTextStyle);
    }
  }
}
