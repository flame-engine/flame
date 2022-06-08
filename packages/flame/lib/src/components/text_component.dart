import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/src/text/text_renderer.dart';
import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';

class TextComponent<T extends TextRenderer> extends PositionComponent {
  String _text;
  T _textRenderer;

  String get text => _text;

  set text(String text) {
    if (_text != text) {
      _text = text;
      updateBounds();
    }
  }

  T get textRenderer => _textRenderer;

  set textRenderer(T textRenderer) {
    _textRenderer = textRenderer;
    updateBounds();
  }

  TextComponent({
    String? text,
    T? textRenderer,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
  })  : _text = text ?? '',
        _textRenderer = textRenderer ?? TextRenderer.createDefault<T>() {
    updateBounds();
  }

  @internal
  void updateBounds() {
    final expectedSize = textRenderer.measureText(_text);
    size.setValues(expectedSize.x, expectedSize.y);
  }

  @override
  void render(Canvas canvas) {
    _textRenderer.render(canvas, text, Vector2.zero());
  }
}
