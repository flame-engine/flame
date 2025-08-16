import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';

class TextComponent<T extends TextRenderer> extends PositionComponent {
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
    super.key,
  }) : _text = text ?? '',
       _textRenderer = textRenderer ?? TextRendererFactory.createDefault<T>() {
    updateBounds();
  }

  String get text => _text;
  String _text;
  set text(String text) {
    if (_text != text) {
      _text = text;
      updateBounds();
    }
  }

  T get textRenderer => _textRenderer;
  T _textRenderer;
  set textRenderer(T textRenderer) {
    _textRenderer = textRenderer;
    updateBounds();
  }

  late InlineTextElement _textElement;

  @internal
  void updateBounds() {
    _textElement = _textRenderer.format(_text);
    final measurements = _textElement.metrics;
    _textElement.translate(0, measurements.ascent);
    size.setValues(measurements.width, measurements.height);
  }

  @override
  void render(Canvas canvas) {
    _textElement.draw(canvas);
  }
}
