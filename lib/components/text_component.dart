import 'dart:ui';

import 'package:flutter/src/painting/text_painter.dart';

import 'component.dart';
import '../position.dart';
import '../text_config.dart';

class TextComponent extends PositionComponent {
  String _text;
  TextConfig _config;

  get text => _text;

  set text(String text) {
    _text = text;
    _updateBox();
  }

  get config => _config;

  set config(TextConfig config) {
    _config = config;
    _updateBox();
  }

  TextComponent(this._text, {TextConfig config = const TextConfig()}) {
    this._config = config;
    _updateBox();
  }

  void _updateBox() {
    TextPainter tp = config.toTextPainter(text);
    this.width = tp.width;
    this.height = tp.height;
  }

  @override
  void render(Canvas c) {
    prepareCanvas(c);
    config.render(c, text, Position.empty());
  }

  @override
  void update(double t) {}
}
