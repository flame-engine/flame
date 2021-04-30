import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';

import '../extensions/vector2.dart';
import '../text.dart';
import 'position_component.dart';

class TextComponent extends PositionComponent {
  String _text;
  TextRenderer _textRenderer;

  String get text => _text;

  set text(String text) {
    if (_text != text) {
      _text = text;
      _updateBox();
    }
  }

  TextRenderer get textRenderer => _textRenderer;

  set textRenderer(TextRenderer textRenderer) {
    _textRenderer = textRenderer;
    _updateBox();
  }

  TextComponent(
    this._text, {
    TextRenderer? textRenderer,
    Vector2? position,
    Vector2? size,
  })  : _textRenderer = textRenderer ?? TextPaint(),
        super(position: position, size: size) {
    _updateBox();
  }

  void _updateBox() {
    final size = textRenderer.measureText(_text);
    size.setValues(size.x, size.y);
  }

  @mustCallSuper
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _textRenderer.render(canvas, text, Vector2.zero());
  }
}
