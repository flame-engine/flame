import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/widgets.dart' hide Image;

import '../extensions/vector2.dart';
import '../palette.dart';
import '../text_config.dart';
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

class TextBoxComponent extends PositionComponent {
  static final Paint _imagePaint = BasicPalette.white.paint
    ..filterQuality = FilterQuality.high;
  Vector2 _gameSize = Vector2.zero();

  final String _text;
  final TextConfig _config;
  final TextBoxConfig _boxConfig;

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
    Vector2 position,
    Vector2 size,
  })  : _text = text,
        _boxConfig = boxConfig ?? TextBoxConfig(),
        _config = config ?? TextConfig(),
        super(position: position, size: size) {
    _lines = [];
    double lineHeight;
    text.split(' ').forEach((word) {
      final possibleLine = _lines.isEmpty ? word : '${_lines.last} $word';
      final painter = _config.toTextPainter(possibleLine);
      lineHeight ??= painter.height;
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
        _updateMaxWidth(_config.toTextPainter(word).width);
      }
    });
    _totalLines = _lines.length;
    _lineHeight = lineHeight ?? 0.0;
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
    var totalCharCount = 0;
    final _currentChar = currentChar;
    for (var i = 0; i < _lines.length; i++) {
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
      var i = 0;
      var totalCharCount = 0;
      final _currentChar = currentChar;
      final _currentLine = currentLine;
      final textWidth = _lines.sublist(0, _currentLine + 1).map((line) {
        final charCount =
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

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    _gameSize = gameSize;
  }

  Future<Image> _redrawCache() {
    final recorder = PictureRecorder();
    final c = Canvas(recorder, _gameSize.toRect());
    _fullRender(c);
    return recorder.endRecording().toImage(width.toInt(), height.toInt());
  }

  void drawBackground(Canvas c) {}

  void _fullRender(Canvas c) {
    drawBackground(c);

    final _currentLine = currentLine;
    var charCount = 0;
    var dy = _boxConfig.margins.top;
    for (var line = 0; line < _currentLine; line++) {
      charCount += _lines[line].length;
      _drawLine(c, _lines[line], dy);
      dy += _lineHeight;
    }
    final max = math.min(currentChar - charCount, _lines[_currentLine].length);
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
