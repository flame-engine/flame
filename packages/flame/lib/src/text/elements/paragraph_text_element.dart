import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/text.dart';
import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';

/// A [TextElement] holding a block of rich text that was laid out by Flutter's
/// paragraph engine.
///
/// The element owns the laid out [TextPainter]; call [dispose] once the
/// element is no longer needed to release it.
///
/// Wraps a text painter that has already had `layout` called on it.
class ParagraphTextElement(final TextPainter _textPainter) extends TextElement {
  /// Lays out [text] within [maxWidth] and wraps the resulting painter.
  ParagraphTextElement.layout(
    InlineSpan text, {
    required double maxWidth,
    TextAlign textAlign = TextAlign.start,
    TextDirection textDirection = TextDirection.ltr,
  }) : this(
         TextPainter(
           text: text,
           textAlign: textAlign,
           textDirection: textDirection,
         )..layout(maxWidth: maxWidth),
       );

  Offset _offset = Offset.zero;

  @visibleForTesting
  TextPainter get textPainter => _textPainter;

  /// The position of the paragraph's top left corner.
  Offset get offset => _offset;

  /// The width of the laid out paragraph.
  double get width => _textPainter.width;

  /// The height of the laid out paragraph.
  double get height => _textPainter.height;

  /// The whole text of this paragraph, without any styling.
  String get plainText => _textPainter.plainText;

  /// Measurements of each laid out line, relative to [offset].
  List<ui.LineMetrics> get lineMetrics => _textPainter.computeLineMetrics();

  /// The text that ended up on each line after line breaking.
  ///
  /// Hard line breaks are not included in the returned strings.
  List<String> get lines {
    final text = plainText;
    final out = <String>[];
    var offset = 0;
    while (offset < text.length) {
      var range = _textPainter.getLineBoundary(TextPosition(offset: offset));
      // Flutter web sometimes reports the range of the previous line instead
      // of the one containing the offset, see
      // https://github.com/flutter/flutter/issues/188874
      if (range.start < offset) {
        range = _textPainter.getLineBoundary(TextPosition(offset: offset + 1));
      }
      final end = max(range.end, offset + 1);
      var line = text.substring(offset, end);
      if (line.endsWith('\n')) {
        line = line.substring(0, line.length - 1);
      }
      out.add(line);
      offset = end;
      if (offset < text.length && text[offset] == '\n') {
        offset++;
      }
    }
    return out;
  }

  @override
  void translate(double dx, double dy) {
    _offset = _offset.translate(dx, dy);
  }

  @override
  void draw(Canvas canvas) {
    _textPainter.paint(canvas, _offset);
  }

  @override
  Rect get boundingBox => _offset & _textPainter.size;

  @override
  void dispose() {
    _textPainter.dispose();
  }

  @override
  String toString() => 'ParagraphTextElement(text: $plainText)';
}
