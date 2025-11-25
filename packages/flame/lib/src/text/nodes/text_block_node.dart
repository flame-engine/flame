import 'dart:ui';

import 'package:flame/src/text/common/utils.dart';
import 'package:flame/text.dart';
import 'package:meta/meta.dart';

abstract class TextBlockNode extends BlockNode {
  TextBlockNode(this.child);

  final InlineTextNode child;

  @mustCallSuper
  @override
  void fillStyles(DocumentStyle stylesheet, InlineTextStyle parentTextStyle) {
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

    final lines = <InlineTextElement>[];
    final horizontalOffset = style.padding.left;
    var verticalOffset = style.padding.top;
    final textAlign = style.textAlign ?? TextAlign.left;
    while (!layoutBuilder.isDone) {
      final element = layoutBuilder.layOutNextLine(
        contentWidth,
        isStartOfLine: true,
      );
      if (element == null) {
        // Not enough horizontal space to lay out. For now we just stop the
        // layout altogether cutting off the remainder of the content. But is
        // there a better alternative?
        break;
      } else {
        final metrics = element.metrics;
        assert(metrics.left == 0 && metrics.baseline == 0);

        final dx =
            horizontalOffset +
            (contentWidth - metrics.width) * _relativeOffset(textAlign);
        final dy = verticalOffset + metrics.ascent;
        element.translate(dx, dy);

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

  double _relativeOffset(TextAlign textAlign) {
    return switch (textAlign) {
      TextAlign.left => 0,
      TextAlign.right => 1,
      TextAlign.center => 0.5,
      // NOTE: we do not support non-LRT text directions
      TextAlign.start => 0,
      TextAlign.end => 1,
      // Not supported by Flame
      TextAlign.justify => throw UnimplementedError(
        'The text rendering pipeline cannot justify text.',
      ),
    };
  }
}
