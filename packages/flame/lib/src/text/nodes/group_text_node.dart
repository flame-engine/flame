import 'package:flame/src/text/elements/group_text_element.dart';
import 'package:flame/src/text/elements/text_element.dart';
import 'package:flame/src/text/nodes/text_node.dart';
import 'package:flame/src/text/styles/document_style.dart';
import 'package:flame/src/text/styles/text_style.dart';

class GroupTextNode extends TextNode {
  GroupTextNode(this.children);

  final List<TextNode> children;

  @override
  void fillStyles(DocumentStyle stylesheet, TextStyle parentTextStyle) {
    textStyle = parentTextStyle;
  }

  @override
  TextNodeLayoutBuilder get layoutBuilder => _GroupTextLayoutBuilder(this);
}

class _GroupTextLayoutBuilder extends TextNodeLayoutBuilder {
  _GroupTextLayoutBuilder(this.node);

  final GroupTextNode node;
  int _currentChildIndex = 0;
  TextNodeLayoutBuilder? _currentChildBuilder;

  @override
  bool get isDone => _currentChildIndex == node.children.length;

  @override
  TextElement? layOutNextLine(double availableWidth) {
    assert(!isDone);
    final out = <TextElement>[];
    var usedWidth = 0.0;
    while (true) {
      if (_currentChildBuilder?.isDone ?? false) {
        _currentChildBuilder = null;
        _currentChildIndex += 1;
        if (_currentChildIndex == node.children.length) {
          break;
        }
      }
      _currentChildBuilder ??= node.children[_currentChildIndex].layoutBuilder;

      final maybeLine =
          _currentChildBuilder!.layOutNextLine(availableWidth - usedWidth);
      if (maybeLine == null) {
        break;
      } else {
        maybeLine.translate(usedWidth, 0);
        out.add(maybeLine);
        usedWidth += maybeLine.metrics.width;
      }
    }
    if (out.isEmpty) {
      return null;
    } else {
      final element = GroupTextElement(out);
      element.translate(0, element.metrics.ascent);
      return element;
    }
  }
}
