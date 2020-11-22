import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/widgets.dart' hide Image;

import '../palette.dart';
import '../text_config.dart';
import '../extensions/vector2.dart';
import 'mixins/resizable.dart';
import 'position_component.dart';

class TextBoxConfig {
  final double maxWidth;
  final EdgeInsets margins;
  final double timePerChar;
  final double dismissDelay;
  final bool growingBox;

  TextBoxConfig({
    this.maxWidth = 200.0,
    this.margins = const EdgeInsets.all(8.0),
    this.timePerChar = 0.0,
    this.dismissDelay = 0.0,
    this.growingBox = false,
  });
}

class TextBoxComponent extends PositionComponent with Resizable {
  static final Paint _imagePaint = BasicPalette.white.paint
    ..filterQuality = FilterQuality.high;

  String _text;
  TextConfig _config;
  TextBoxConfig _boxConfig;

  List<String> _lines;
  double _maxLineWidth = 0.0;
  double _lineHeight;
  int _totalLines;

  double _lifeTime = 0.0;
  Image _cache;
  int _previousChar;

  String get text => _text;

  TextConfig get config => _config;

  TextBoxConfig get boxConfig => _boxConfig;

  TextBoxComponent(
    String text, {
    TextConfig config,
    TextBoxConfig boxConfig,
  }) {
    _boxConfig = boxConfig ?? TextBoxConfig();
    _config = config ?? TextConfig();
    _text = text;
    _lines = [];
    text.split(' ').forEach((word) {
      final possibleLine = _lines.isEmpty ? word : _lines.last + ' ' + word;
      final painter = config.toTextPainter(possibleLine);
      _lineHeight ??= painter.height;
      if (painter.width <=
          _boxConfig.maxWidth - _boxConfig.margins.horizontal) {
        if (_lines.isNotEmpty) {
          _lines.last = possibleLine;
        } else {
          _lines.add(possibleLine);
        }
        _updateMaxWidth(painter.width);
      } else {
        _lines.add(word);
        _updateMaxWidth(config.toTextPainter(word).width);
      }
    });
    _totalLines = _lines.length;
  }

  void _updateMaxWidth(double w) {
    if (w > _maxLineWidth) {
      _maxLineWidth = w;
    }
  }

  double get totalCharTime => _text.length * _boxConfig.timePerChar;

  bool get finished => _lifeTime > totalCharTime + _boxConfig.dismissDelay;

  int get currentChar => _boxConfig.timePerChar == 0.0
      ? _text.length
      : math.min(_lifeTime ~/ _boxConfig.timePerChar, _text.length);

  int get currentLine {
    int totalCharCount = 0;
    final int _currentChar = currentChar;
    for (int i = 0; i < _lines.length; i++) {
      totalCharCount += _lines[i].length;
      if (totalCharCount > _currentChar) {
        return i;
      }
    }
    return _lines.length - 1;
  }

  @override
  Vector2 get size => Vector2(width, height);

  double getLineWidth(String line, int charCount) {
    return _config
        .toTextPainter(line.substring(0, math.min(charCount, line.length)))
        .width;
  }

  double _cachedWidth;

  @override
  double get width {
    if (_cachedWidth != null) {
      return _cachedWidth;
    }
    if (_boxConfig.growingBox) {
      int i = 0;
      int totalCharCount = 0;
      final int _currentChar = currentChar;
      final int _currentLine = currentLine;
      final double textWidth = _lines.sublist(0, _currentLine + 1).map((line) {
        final int charCount =
            (i < _currentLine) ? line.length : (_currentChar - totalCharCount);
        totalCharCount += line.length;
        i++;
        return getLineWidth(line, charCount);
      }).reduce(math.max);
      _cachedWidth = textWidth + _boxConfig.margins.horizontal;
    } else {
      _cachedWidth = _boxConfig.maxWidth + _boxConfig.margins.horizontal;
    }
    return _cachedWidth;
  }

  @override
  double get height {
    if (_boxConfig.growingBox) {
      return _lineHeight * _lines.length + _boxConfig.margins.vertical;
    } else {
      return _lineHeight * _totalLines + _boxConfig.margins.vertical;
    }
  }

  @override
  void render(Canvas c) {
    if (_cache == null) {
      return;
    }
    super.render(c);
    c.drawImage(_cache, Offset.zero, _imagePaint);
  }

  Future<Image> _redrawCache() {
    final PictureRecorder recorder = PictureRecorder();
    final Canvas c = Canvas(recorder, gameSize.toRect());
    _fullRender(c);
    return recorder.endRecording().toImage(width.toInt(), height.toInt());
  }

  void drawBackground(Canvas c) {}

  void _fullRender(Canvas c) {
    drawBackground(c);

    final int _currentLine = currentLine;
    int charCount = 0;
    double dy = _boxConfig.margins.top;
    for (int line = 0; line < _currentLine; line++) {
      charCount += _lines[line].length;
      _drawLine(c, _lines[line], dy);
      dy += _lineHeight;
    }
    final int max =
        math.min(currentChar - charCount, _lines[_currentLine].length);
    _drawLine(c, _lines[_currentLine].substring(0, max), dy);
  }

  void _drawLine(Canvas c, String line, double dy) {
    _config.toTextPainter(line).paint(c, Offset(_boxConfig.margins.left, dy));
  }

  void redrawLater() async {
    _cache = await _redrawCache();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _lifeTime += dt;
    if (_previousChar != currentChar) {
      _cachedWidth = null;
      redrawLater();
    }
    _previousChar = currentChar;
  }
}
