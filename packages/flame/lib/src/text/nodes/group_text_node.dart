
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
  TextNodeLayoutBuilder get layoutBuilder => throw UnimplementedError();
}
