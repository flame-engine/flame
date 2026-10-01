import 'dart:math';

import 'package:flame/src/text/common/utils.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart' hide TextStyle;
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
  /// The inline content is laid out as a single left-to-right paragraph by
  /// Flutter, which takes care of line breaking, alignment, kerning and
  /// ligatures across differently styled spans.
  ///
  /// All late variables must be initialized prior to calling this method.
  @override
  BlockElement format(double availableWidth) {
    final blockWidth = availableWidth;
    final contentWidth = max(blockWidth - style.padding.horizontal, 0.0);
    final textAlign = style.textAlign ?? TextAlign.left;

    final paragraph = ParagraphTextElement.layout(
      child.toInlineSpan(),
      maxWidth: contentWidth,
      textAlign: textAlign,
    );
    final dx =
        style.padding.left +
        (contentWidth - paragraph.width) * _relativeOffset(textAlign);
    paragraph.translate(dx, style.padding.top);

    final blockHeight = paragraph.height + style.padding.vertical;
    final background = makeBackground(
      style.background,
      blockWidth,
      blockHeight,
    );
    final elements = background == null ? [paragraph] : [background, paragraph];
    return GroupElement(
      width: blockWidth,
      height: blockHeight,
      children: elements,
    );
  }

  double _relativeOffset(TextAlign textAlign) {
    return switch (textAlign) {
      TextAlign.left || TextAlign.start || TextAlign.justify => 0,
      TextAlign.right || TextAlign.end => 1,
      TextAlign.center => 0.5,
    };
  }
}
