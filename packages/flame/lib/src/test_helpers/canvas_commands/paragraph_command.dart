import 'dart:ui';
import 'command.dart';

/// canvas.drawParagraph()
class ParagraphCommand extends CanvasCommand {
  ParagraphCommand(this.offset);
  final Offset offset;

  @override
  bool equals(ParagraphCommand other) => eq(offset, other.offset);

  @override
  String toString() {
    return 'drawParagraph(${repr(offset)})';
  }
}
