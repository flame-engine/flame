import 'package:flame/src/text/elements/text_element.dart';
import 'package:flame/src/text/styles/document_style.dart';
import 'package:flame/src/text/styles/text_style.dart';

abstract class TextNode {
  late TextStyle textStyle;

  void fillStyles(DocumentStyle stylesheet, TextStyle parentTextStyle);

  TextNodeLayoutBuilder get layoutBuilder;
}

abstract class TextNodeLayoutBuilder {
  TextElement? layOutNextLine(double availableWidth);
  bool get isDone;
}
