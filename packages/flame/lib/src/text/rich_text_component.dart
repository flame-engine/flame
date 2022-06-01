
import 'dart:ui';

import 'package:flame/src/components/position_component.dart';
import 'package:flame/src/text/block/text_block.dart';

class RichTextComponent extends PositionComponent {
  RichTextComponent(this._text) {
    _text.layout();
    width = _text.width;
    height = _text.height;
  }

  final TextBlock _text;

  @override
  void render(Canvas canvas) {
    _text.render(canvas);
  }
}
