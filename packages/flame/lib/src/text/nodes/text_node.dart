import 'package:flame/text.dart';

abstract class TextNode<T extends FlameTextStyle> {
  T get style;

  void fillStyles(DocumentStyle stylesheet, InlineTextStyle parentTextStyle);
}
