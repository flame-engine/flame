import 'package:flame/src/text/nodes/inline_text_node.dart';
import 'package:flame/text.dart';

/// An [InlineTextNode] representing plain text.
class PlainTextNode extends InlineTextNode {
  PlainTextNode(this.text);

  final String text;

  @override
  void fillStyles(DocumentStyle stylesheet, InlineTextStyle parentTextStyle) {
    style = parentTextStyle;
  }

  @override
  TextNodeLayoutBuilder get layoutBuilder => _PlainTextLayoutBuilder(this);
}

class _PlainTextLayoutBuilder extends TextNodeLayoutBuilder {
  _PlainTextLayoutBuilder(this.node)
    : renderer = node.style.asTextRenderer(),
      words = node.text.split(' ');

  final PlainTextNode node;
  final TextRenderer renderer;
  final List<String> words;
  int index0 = 0;
  int index1 = 1;

  @override
  bool get isDone => index1 > words.length;

  @override
  InlineTextElement? layOutNextLine(
    double availableWidth, {
    required bool isStartOfLine,
  }) {
    InlineTextElement? tentativeLine;
    int? tentativeIndex0;
    while (index1 <= words.length) {
      final prependSpace = index0 == 0 || isStartOfLine ? '' : ' ';
      final textPiece = prependSpace + words.sublist(index0, index1).join(' ');
      final formattedPiece = renderer.format(textPiece);
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
