import 'dart:math';
import 'dart:ui';

import 'package:flame/src/text/block/background_element.dart';
import 'package:flame/src/text/block/block_element.dart';
import 'package:flame/src/text/nodes.dart';
import 'package:flame/src/text/styles/document_style.dart';

class DocumentElement {
  DocumentElement(this._document, this._style)
    : _width = _style.width;

  final DocumentNode _document;
  final DocumentStyle _style;
  final List<BlockElement> _elements = [];
  BackgroundElement? _background;

  double get width => _width;
  double _width;
  set width(double value) {
    assert(!_laidOut, 'Cannot change width after the document was laid out');
    _width = value;
  }

  double _height = 0;

  /// Will be set to true once the document is laid out
  bool _laidOut = false;

  void layout() {
    final contentWidth = width - _style.padding.horizontal;
    var verticalOffset = 0.0;
    var currentMargin = 0.0;
    for (final node in _document.children) {
      final nodeStyle = _style.styleFor(node);
      verticalOffset += _collapseMargin(currentMargin, nodeStyle.margin.top);
      final nodeElement = nodeStyle.format(node)
        ..width = contentWidth
        ..translate(0, verticalOffset);
      _elements.add(nodeElement);
      currentMargin = nodeStyle.margin.bottom;
    }
    verticalOffset += _collapseMargin(currentMargin, _style.padding.bottom);
    _height = verticalOffset;
    _background = _style.backgroundStyle?.format(_width, _height);
    _background?.layout();
    _laidOut = true;
  }

  void render(Canvas canvas) {
    assert(_laidOut, 'The document needs to be laid out before rendering');
    _background?.render(canvas);
    for (final element in _elements) {
      element.render(canvas);
    }
  }

  double _collapseMargin(double margin1, double margin2) {
    if (margin1 >= 0) {
      return (margin2 < 0) ? margin1 + margin2 : max(margin1, margin2);
    } else {
      return (margin2 < 0) ? min(margin1, margin2) : margin1 + margin2;
    }
  }
}
