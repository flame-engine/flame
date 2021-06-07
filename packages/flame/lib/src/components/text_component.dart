import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';

import '../extensions/vector2.dart';
import '../text.dart';
import 'position_component.dart';

class TextComponent<T extends TextRenderer> extends PositionComponent {
  String _text;
  T _textRenderer;

  String get text => _text;

  set text(String text) {
    if (_text != text) {
      _text = text;
      _updateBox();
    }
  }

  T get textRenderer => _textRenderer;

  set textRenderer(T textRenderer) {
    _textRenderer = textRenderer;
    _updateBox();
  }

  TextComponent(
    this._text, {
    T? textRenderer,
    Vector2? position,
    Vector2? size,
    int? priority,
  })  : _textRenderer = textRenderer ?? TextRenderer.createDefault<T>(),
        super(position: position, size: size, priority: priority) {
    _updateBox();
  }

  void _updateBox() {
    final expectedSize = textRenderer.measureText(_text);
    size.setValues(expectedSize.x, expectedSize.y);
  }

  @mustCallSuper
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _textRenderer.render(canvas, text, Vector2.zero());
  }
}
