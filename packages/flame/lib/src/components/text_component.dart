import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/src/text/formatter_text_renderer.dart';
import 'package:flame/src/text/inline/text_element.dart';
import 'package:flame/src/text/text_renderer.dart';
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
  })  : _text = text ?? '',
        _textRenderer = textRenderer ?? TextRenderer.createDefault<T>() {
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

  TextElement? _textElement;

  @internal
  void updateBounds() {
    if (_textRenderer is FormatterTextRenderer) {
      _textElement =
          (_textRenderer as FormatterTextRenderer).formatter.format(_text);
      final measurements = _textElement!.lastLine.metrics;
      _textElement!.lastLine.translate(0, measurements.ascent);
      size.setValues(measurements.width, measurements.height);
    } else {
      final expectedSize = textRenderer.measureText(_text);
      size.setValues(expectedSize.x, expectedSize.y);
    }
  }

  @override
  void render(Canvas canvas) {
    if (_textElement != null) {
      _textElement!.render(canvas);
    } else {
      _textRenderer.render(canvas, text, Vector2.zero());
    }
  }
}
