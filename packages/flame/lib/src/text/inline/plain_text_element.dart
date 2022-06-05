import 'package:flame/src/text/inline/text_element.dart';
import 'package:flame/src/text/line_metrics.dart';
import 'package:flame/src/text/text_line.dart';
import 'package:flutter/rendering.dart';

class PlainTextElement extends TextElement implements TextLine {
  PlainTextElement(this._textPainter)
      : _ascent = _textPainter
            .computeDistanceToActualBaseline(TextBaseline.alphabetic);

  final TextPainter _textPainter;
  final double _ascent;
  double? _x0;
  double? _y0;

  @override
  bool get isLaidOut => _x0 != null && _y0 != null;

  @override
  void resetLayout() => _x0 = null;

  @override
  LayoutResult layOutNextLine(LineMetrics bounds) {
    if (bounds.width < _textPainter.width) {
      return LayoutResult.didNotAdvance;
    }
    _x0 = bounds.left;
    _y0 = bounds.baseline - _ascent;
    return LayoutResult.done;
  }

  @override
  Iterable<TextLine> get lines => _x0 == null ? [] : [this];

  @override
  TextLine get lastLine => this;

  @override
  LineMetrics get metrics {
    assert(isLaidOut);
    return LineMetrics(
      baseline: _y0! + _ascent,
      left: _x0!,
      width: _textPainter.width,
      ascent: _ascent,
      descent: _textPainter.height - _ascent,
    );
  }

  @override
  void translate(double dx, double dy) {
    _x0 = _x0! + dx;
    _y0 = _y0! + dy;
  }

  @override
  void render(Canvas canvas) {
    assert(isLaidOut);
    _textPainter.paint(canvas, Offset(_x0!, _y0!));
  }
}
