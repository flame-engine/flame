import 'package:flame/src/text/elements/text_element.dart';
import 'package:flame/src/text/formatters/text_formatter.dart';
import 'package:flame/src/text/nodes/text_node.dart';
import 'package:flame/src/text/styles/document_style.dart';
import 'package:flame/src/text/styles/flame_text_style.dart';

class PlainTextNode extends TextNode {
  PlainTextNode(this.text);

  final String text;

  @override
  void fillStyles(DocumentStyle stylesheet, FlameTextStyle parentTextStyle) {
    textStyle = parentTextStyle;
  }

  @override
  TextNodeLayoutBuilder get layoutBuilder => _PlainTextLayoutBuilder(this);
}

class _PlainTextLayoutBuilder extends TextNodeLayoutBuilder {
  _PlainTextLayoutBuilder(this.node)
      : formatter = node.textStyle.asTextFormatter(),
        words = node.text.split(' ');

  final PlainTextNode node;
  final TextFormatter formatter;
  final List<String> words;
  int index0 = 0;
  int index1 = 1;

  @override
  bool get isDone => index1 > words.length;

  @override
  TextElement? layOutNextLine(double availableWidth) {
    TextElement? tentativeLine;
    int? tentativeIndex0;
    while (index1 <= words.length) {
      final textPiece = words.sublist(index0, index1).join(' ');
      final formattedPiece = formatter.format(textPiece);
      if (formattedPiece.metrics.width > availableWidth) {
        break;
      } else {
        tentativeLine = formattedPiece;
        tentativeIndex0 = index1;
        index1 += 1;
      }
    }
    if (tentativeLine != null) {
      assert(tentativeIndex0 != 0 && tentativeIndex0! > index0);
      index0 = tentativeIndex0!;
      return tentativeLine;
    } else {
      return null;
    }
  }
}
