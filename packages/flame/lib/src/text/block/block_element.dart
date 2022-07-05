
import 'dart:ui';

import 'package:flame/src/text/nodes.dart';
import 'package:flame/src/text/styles/block_style.dart';

class BlockElement {
  BlockElement(this._block, this._style);

  final BlockNode _block;
  final BlockStyle _style;

  void layout() {}

  void render(Canvas canvas) {}
}
