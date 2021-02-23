import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';

import '../extensions/vector2.dart';
import '../text_config.dart';
import 'position_component.dart';

class TextComponent extends PositionComponent {
  String _text;
  TextConfig _config;

  TextPainter _tp;

  String get text => _text;

  set text(String text) {
    if (_text != text) {
      _text = text;
      _updateBox();
    }
  }

  TextConfig get config => _config;

  set config(TextConfig config) {
    _config = config;
    _updateBox();
  }

  TextComponent(
    this._text, {
    TextConfig config,
    Vector2 position,
    Vector2 size,
  })  : assert(_text != null),
        _config = config ?? TextConfig(),
        super(position: position, size: size) {
    _updateBox();
  }

  void _updateBox() {
    _tp = config.toTextPainter(_text);
    size.setValues(_tp.width, _tp.height);
  }

  @mustCallSuper
  @override
  void render(Canvas c) {
    super.render(c);
    _tp.paint(c, Offset.zero);
  }
}
