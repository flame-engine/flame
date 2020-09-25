import 'dart:ui';

import 'package:flutter/painting.dart';

import '../text_config.dart';
import 'component.dart';

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

  TextComponent(this._text, {TextConfig config}) {
    _config = config ?? TextConfig();
    _updateBox();
  }

  void _updateBox() {
    _tp = config.toTextPainter(_text);
    width = _tp.width;
    height = _tp.height;
  }

  @override
  void render(Canvas c) {
    prepareCanvas(c);
    _tp.paint(c, Offset.zero);
  }
}
