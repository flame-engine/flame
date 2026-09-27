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
  double get leadingRunWidth {
    // Past the first word, the remaining content starts with a space.
    if (isDone || index0 > 0 || words.first.isEmpty) {
      return 0;
    }
    return renderer.format(words.first).metrics.width;
  }

  @override
  bool get hasBreakOpportunity => !isDone && (index0 > 0 || words.length > 1);

  @override
  InlineTextElement? layOutNextLine(
    double availableWidth, {
    required bool isStartOfLine,
    double trailingWidth = 0,
  }) {
    InlineTextElement? tentativeLine;
    int? tentativeIndex0;
    while (index1 <= words.length) {
      final prependSpace = index0 == 0 || isStartOfLine ? '' : ' ';
      final textPiece = prependSpace + words.sublist(index0, index1).join(' ');
      final formattedPiece = renderer.format(textPiece);
      // The last word is glued to what follows unless the text ends in a
      // space (in which case the last word is empty).
      final isGlued = index1 == words.length && words.last.isNotEmpty;
      final maxWidth = availableWidth - (isGlued ? trailingWidth : 0);
      if (formattedPiece.metrics.width > maxWidth) {
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
    } else if (isStartOfLine && trailingWidth > 0) {
      // The glued run is wider than a whole line, so it has to be broken.
      return layOutNextLine(availableWidth, isStartOfLine: true);
    } else {
      return null;
    }
  }
}
