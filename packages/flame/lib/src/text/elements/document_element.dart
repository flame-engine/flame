import 'dart:math';
import 'dart:ui';

import 'package:flame/src/text/elements/element.dart';
import 'package:flame/src/text/nodes.dart';
import 'package:flame/src/text/styles/document_style.dart';

class DocumentElement extends Element {
  DocumentElement({
    required DocumentNode document,
    required DocumentStyle style,
    required double width,
    required double height,
  })  : _document = document,
        _style = style,
        _width = width,
        _height = height;

  final DocumentNode _document;
  final DocumentStyle _style;
  final List<Element> _elements = [];
  Element? _background;

  final double _width;
  double _height;

  /// Will be set to true once the document is laid out
  bool _laidOut = false;

  @override
  void layout() {
    final contentWidth = _width -
        _style.padding.horizontal -
        (_style.backgroundStyle?.borderWidths.horizontal ?? 0);
    var verticalOffset =
        _style.padding.top + (_style.backgroundStyle?.borderWidths.top ?? 0);
    var currentMargin = _style.padding.top;
    for (final node in _document.children) {
      final blockStyle = _style.styleForBlockNode(node);
      verticalOffset += _collapseMargin(currentMargin, blockStyle.margin.top);
      final nodeElement = blockStyle.format(node, parentWidth: contentWidth);
      _elements.add(nodeElement..translate(0, verticalOffset));
      currentMargin = blockStyle.margin.bottom;
    }
    _height = verticalOffset +
        _collapseMargin(currentMargin, _style.padding.bottom) +
        (_style.backgroundStyle?.borderWidths.bottom ?? 0);
    _background = _style.backgroundStyle?.format(_width, _height);
    _background?.layout();
    _laidOut = true;
  }

  @override
  void translate(double dx, double dy) {
    _background?.translate(dx, dy);
    _elements.forEach((element) => element.translate(dx, dy));
  }

  @override
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
