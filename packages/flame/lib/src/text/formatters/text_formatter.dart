import 'package:flame/src/text/elements/text_element.dart';

/// [TextFormatter] is an abstract interface for a class that can convert an
/// arbitrary string of text into a renderable [TextElement].
abstract class TextFormatter {
  TextElement format(String text);
}
