import 'dart:ui';

import 'package:flutter/painting.dart';

import 'component.dart';
import '../position.dart';
import '../text_config.dart';

class TextComponent extends PositionComponent {
  String _text;
  TextConfig _config;

  TextPainter _tp;
  Offset _translatedOffset;

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

  TextComponent(this._text, {TextConfig config = const TextConfig()}) {
    _config = config;
    _updateBox();
  }

  void _updateBox() {
    _tp = config.toTextPainter(_text);
    width = _tp.width;
    height = _tp.height;

    _updateOffset(Position.empty());
  }

  void _updateOffset(Position p) {
    final Position translatedPosition =
        anchor.translate(p, Position.fromSize(_tp.size));
    _translatedOffset = translatedPosition.toOffset();
  }

  @override
  void render(Canvas c) {
    prepareCanvas(c);
    _tp.paint(c, _translatedOffset);
  }

  @override
  void update(double t) {}
}
