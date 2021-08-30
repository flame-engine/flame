import 'dart:ui';
import 'command.dart';

/// canvas.drawRect()
class RectCommand extends CanvasCommand {
  RectCommand(this.rect, this.paint);
  final Rect rect;
  final Paint? paint;

  @override
  bool equals(RectCommand other) {
    return eq(rect, other.rect) && eq(paint, other.paint);
  }

  @override
  String toString() {
    return 'drawRect(${repr(rect)}, ${repr(paint)})';
  }
}
