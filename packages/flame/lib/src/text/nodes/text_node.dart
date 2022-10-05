import 'package:flame/src/text/elements/text_element.dart';
import 'package:flame/src/text/styles/document_style.dart';
import 'package:flame/src/text/styles/flame_text_style.dart';

abstract class TextNode {
  late FlameTextStyle textStyle;

  void fillStyles(DocumentStyle stylesheet, FlameTextStyle parentTextStyle);

  TextNodeLayoutBuilder get layoutBuilder;
}

abstract class TextNodeLayoutBuilder {
  TextElement? layOutNextLine(double availableWidth);
  bool get isDone;
}
