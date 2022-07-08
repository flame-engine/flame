import 'dart:ui';

import 'package:flame/src/text/elements/element.dart';
import 'package:flame/src/text/nodes.dart';
import 'package:flame/src/text/styles/block_style.dart';

class BlockElement extends Element {
  BlockElement(this._block, this._style);

  final BlockNode _block;
  final BlockStyle _style;
  double width = 0;

  @override
  void layout() {}

  @override
  void render(Canvas canvas) {}

  @override
  void translate(double dx, double dy) {}
}
