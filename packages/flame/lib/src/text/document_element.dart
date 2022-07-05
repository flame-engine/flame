
import 'dart:ui';

import 'package:flame/src/text/block/block_element.dart';
import 'package:flame/src/text/nodes.dart';
import 'package:flame/src/text/styles/document_style.dart';

class DocumentElement {
  DocumentElement(this._document, this._style);

  final DocumentNode _document;
  final DocumentStyle _style;
  final List<BlockElement> _elements = [];

  void layout() {
    final documentWidth = _style.width;
    final contentWidth = documentWidth - _style.padding.horizontal;
    var verticalOffset = _style.padding.top;
    for (final node in _document.children) {
      final nodeStyle = _style.styleFor(node);
      _elements.add(nodeStyle.format(node));
    }
  }

  void render(Canvas canvas) {}
}
