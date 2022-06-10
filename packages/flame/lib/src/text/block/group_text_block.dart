import 'dart:ui';

import 'package:flame/src/text/block/text_block.dart';

class GroupTextBlock extends TextBlock {
  GroupTextBlock(this._children);

  final List<TextBlock> _children;

  @override
  void layout() {
    var totalHeight = 0.0;
    for (final child in _children) {
      child.width = width;
      child.layout();
      child.translate(0, totalHeight);
      totalHeight += child.height;
    }
    height = totalHeight;
    super.layout();
  }

  @override
  void translate(double dx, double dy) {
    _children.forEach((child) => child.translate(dx, dy));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _children.forEach((element) => element.render(canvas));
  }
}
