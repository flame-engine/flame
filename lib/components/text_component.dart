import 'dart:ui';

import 'package:flutter/painting.dart';

import 'component.dart';
import '../position.dart';
import '../text_config.dart';

class TextComponent extends PositionComponent {
  String _text;
  TextConfig _config;

  String get text => _text;

  set text(String text) {
    _text = text;
    _updateBox();
  }

  TextConfig get config => _config;

  set config(TextConfig config) {
    _config = config;
    _updateBox();
  }

  TextComponent(this._text, {TextConfig config = const TextConfig()}) {
    _config = config;
    _updateBox();
  }

  void _updateBox() {
    final TextPainter tp = config.toTextPainter(text);
    width = tp.width;
    height = tp.height;
  }

  @override
  void render(Canvas c) {
    prepareCanvas(c);
    config.render(c, text, Position.empty());
  }

  @override
  void update(double t) {}
}
